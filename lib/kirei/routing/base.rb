# typed: strict
# frozen_string_literal: true

# rubocop:disable Metrics
module Kirei
  module Routing
    class Base
      extend T::Sig

      NOT_FOUND = T.let([404, {}, ["Not Found"]], RackResponseType) # rubocop:disable Style/MutableConstant
      # Oj raises EncodingError for malformed input in the modes Kirei uses, and
      # Oj::ParseError for other parse failures.
      JSON_PARSE_ERRORS = T.let([Oj::ParseError, EncodingError].freeze, T::Array[T.class_of(StandardError)])

      sig { params(params: T::Hash[String, T.untyped]).void }
      def initialize(params: {})
        @router = T.let(Router.instance, Router)
        @params = T.let(params, T::Hash[String, T.untyped])
      end

      sig { returns(T::Hash[String, T.untyped]) }
      attr_reader :params

      sig { returns(Router) }
      attr_reader :router; private :router

      sig { params(env: RackEnvType).returns(RackResponseType) }
      def call(env)
        statsd_timing_tags = T.let({}, T::Hash[String, T.untyped])
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
        status = 500 # we use it in the "ensure" block, so we need to define early (Sorbet doesn't like `status ||= 418`)

        http_verb = Verb.deserialize(env.fetch("REQUEST_METHOD"))
        req_path = request_path(env)
        #
        # TODO: reject requests from unexpected hosts -> allow configuring allowed hosts in a `cors.rb` file
        #   ( offer a scaffold for this file )
        # -> use https://github.com/cyu/rack-cors ?
        #

        lookup_verb = http_verb == Verb::HEAD ? Verb::GET : http_verb
        result = router.resolve(lookup_verb, req_path)
        return NOT_FOUND if result.nil?

        route, path_params = result

        router.current_env = env # expose the env to the controller

        params = case http_verb
                 when Verb::GET
                   query = T.cast(env.fetch("QUERY_STRING"), String)
                   query.split("&").to_h do |p|
                     k, v = p.split("=")
                     k = T.cast(k, String)
                     [k, v]
                   end
                 when Verb::POST, Verb::PUT, Verb::PATCH
                   parse_request_body(env)
                 when Verb::HEAD, Verb::DELETE, Verb::OPTIONS
                   {}
                 else
                   T.absurd(http_verb)
        end

        params.merge!(path_params)

        req_id = T.cast(env["HTTP_X_REQUEST_ID"], T.nilable(String))
        req_id ||= "req_#{App.environment}_#{SecureRandom.uuid}"
        Thread.current[:request_id] = req_id

        controller = route.controller
        before_hooks = collect_hooks(controller, :before_hooks)
        run_hooks(before_hooks)

        Kirei::Logging::Logger.call(
          level: Kirei::Logging::Level::INFO,
          label: "Request Started",
          meta: {
            "http.method" => route.verb.serialize,
            "http.route" => route.path,
            "http.host" => env.fetch("HTTP_HOST"),
            "http.request_params" => params,
            "http.client_ip" => env.fetch("CF-Connecting-IP", env.fetch("REMOTE_ADDR")),
          },
        )

        statsd_timing_tags["controller"] = controller.name
        statsd_timing_tags["route"] = route.action

        status, headers, response_body = case http_verb
                                         when Verb::HEAD, Verb::OPTIONS
                                           [200, {}, []]
                                         when Verb::GET, Verb::POST, Verb::PUT, Verb::PATCH, Verb::DELETE
                                           T.cast(
                                             controller.new(params: params).public_send(route.action),
                                             RackResponseType,
                                           )
                                         else
                                           T.absurd(http_verb)
        end

        after_hooks = collect_hooks(controller, :after_hooks)
        run_hooks(after_hooks)

        headers["X-Request-Id"] ||= req_id

        default_headers.each do |header_name, default_value|
          headers[header_name] ||= default_value
        end

        add_cors_headers(headers, env)

        [
          status,
          headers,
          response_body,
        ]
      rescue RequestRejected => e
        status = e.status
        error = Errors::JsonApiError.new(code: e.code, detail: e.message)
        body = Oj.dump({ "errors" => [error.serialize] }, Kirei::OJ_OPTIONS)
        response_body = [body]

        [status, { "Content-Type" => "application/json; charset=utf-8" }, response_body]
      rescue StandardError => e
        status = 500

        Kirei::Logging::Logger.call(
          level: Kirei::Logging::Level::ERROR,
          label: "Unhandled Exception",
          meta: {
            "error.class" => e.class.name,
            "error.message" => e.message,
            "error.backtrace" => e.backtrace&.first(10)&.join("\n"),
          },
        )

        detail = if Kirei::App.environment == "development"
          "#{e.class}: #{e.message}\n#{e.backtrace&.first(10)&.join("\n")}"
        else
          "An unexpected error occurred"
        end

        error = Errors::JsonApiError.new(code: "internal_server_error", detail: detail)
        body = Oj.dump({ "errors" => [error.serialize] }, Kirei::OJ_OPTIONS)
        response_body = [body]

        [status, { "Content-Type" => "application/json; charset=utf-8" }, response_body]
      ensure
        stop = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
        if start && statsd_timing_tags # early return for 404
          latency_in_ms = stop - start
          Logging::Metric.inject_defaults(statsd_timing_tags)
          App.config.metrics_backend.measure("request", latency_in_ms, tags: statsd_timing_tags)

          Kirei::Logging::Logger.call(
            level: status >= 500 ? Kirei::Logging::Level::ERROR : Kirei::Logging::Level::INFO,
            label: "Request Finished",
            meta: { "response.body" => response_body, "response.latency_in_ms" => latency_in_ms },
          )
        end

        # reset global variables after the request has been served
        # and after all "after" hooks have run to avoid leaking
        router.current_env = nil
        Thread.current[:enduser_id] = nil
        Thread.current[:request_id] = nil
      end

      # `PATH_INFO` is the Rack-specified key. `REQUEST_PATH` is a Puma
      # extension that Falcon does not set.
      sig { params(env: RackEnvType).returns(String) }
      private def request_path(env)
        path = T.cast(env.fetch("PATH_INFO", nil), T.nilable(String))
        return path unless path.nil? || path.empty?

        T.cast(env.fetch("REQUEST_PATH"), String)
      end

      #
      # * "status": defaults to 200
      # * "headers": Kirei adds some default headers for security, but the user can override them
      #
      sig do
        params(
          body: String,
          status: Integer,
          headers: T::Hash[String, String],
        ).returns(RackResponseType)
      end
      def render(body, status: 200, headers: {})
        [
          status,
          headers,
          [body],
        ]
      end

      #
      # Renders a JSON response. Accepts:
      #   - String: treated as pre-serialized JSON (pass-through)
      #   - Hash / Array: serialized via Oj.dump
      #   - Object responding to #serialize (e.g. T::Struct): calls #serialize,
      #     then Oj.dump if the result is not already a String
      #   - Anything else: raises ArgumentError
      #
      sig do
        params(
          data: T.untyped,
          status: Integer,
          headers: T::Hash[String, String],
        ).returns(RackResponseType)
      end
      def render_json(data, status: 200, headers: {})
        body = case data
               when String
                 data
               when Hash, Array
                 Oj.dump(data, Kirei::OJ_OPTIONS)
               else
                 unless data.respond_to?(:serialize)
                   raise ArgumentError,
                         "render_json expects a String, Hash, Array, or an object responding to #serialize, " \
                         "got #{data.class}"
                 end

                 result = data.serialize
                 result.is_a?(String) ? result : Oj.dump(result, Kirei::OJ_OPTIONS)
        end

        render(body, status: status, headers: headers)
      end

      #
      # Renders a JSON:API-compliant error response.
      # Wraps an array of JsonApiError structs into { "errors": [...] }.
      #
      sig do
        params(
          errors: T::Array[Errors::JsonApiError],
          status: Integer,
          headers: T::Hash[String, String],
        ).returns(RackResponseType)
      end
      def render_error(errors, status: 422, headers: {})
        render_json({ "errors" => errors.map(&:serialize) }, status: status, headers: headers)
      end

      #
      # Renders a response from a Services::Result.
      # On success, delegates to render_json with the result's value.
      # On failure, delegates to render_error with the result's errors.
      #
      sig do
        params(
          result: Services::Result[T.untyped],
          status_success: Integer,
          status_failure: Integer,
          headers: T::Hash[String, String],
        ).returns(RackResponseType)
      end
      def render_result(result, status_success: 200, status_failure: 400, headers: {})
        if result.success?
          render_json(result.result, status: status_success, headers: headers)
        else
          render_error(result.errors, status: status_failure, headers: headers)
        end
      end

      sig { returns(T::Hash[String, String]) }
      def default_headers
        {
          # security relevant headers
          "X-Frame-Options" => "DENY",
          "X-Content-Type-Options" => "nosniff",
          "X-XSS-Protection" => "1; mode=block", # for legacy clients/browsers
          "Strict-Transport-Security" => "max-age=31536000; includeSubDomains", # for HTTPS
          "Cache-Control" => "no-store", # the user should set that if caching is needed
          "Referrer-Policy" => "strict-origin-when-cross-origin",
          "Content-Security-Policy" => "default-src 'none'; frame-ancestors 'none'",

          # other headers
          "Content-Type" => "application/json; charset=utf-8",
        }
      end

      sig { params(headers: T::Hash[String, String], env: RackEnvType).void }
      def add_cors_headers(headers, env)
        origin = T.cast(env.fetch("HTTP_ORIGIN", nil), T.nilable(String))
        return if origin.nil?

        allowed_origins = Kirei::App.config.allowed_origins
        return unless allowed_origins.include?(origin)

        headers["Access-Control-Allow-Origin"] = origin
        headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, PATCH, DELETE, OPTIONS"
        headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, Referer"
        headers["Access-Control-Allow-Credentials"] = "true"
      end

      sig { params(hooks: NilableHooksType).void }
      private def run_hooks(hooks)
        return if hooks.nil? || hooks.empty?

        hooks.each(&:call)
      end

      sig do
        params(
          controller: T.class_of(Controller),
          hooks_type: Symbol,
        ).returns(NilableHooksType)
      end
      private def collect_hooks(controller, hooks_type)
        result = T.let(Set.new, T::Set[T.proc.void])

        controller.ancestors.reverse.each do |ancestor|
          next unless ancestor < Controller

          supported_hooks = %i[before_hooks after_hooks]
          unless supported_hooks.include?(hooks_type)
            raise "Unexpected hook type, got #{hooks_type}, expected one of: #{supported_hooks.join(",")}"
          end

          hooks = T.let(ancestor.public_send(hooks_type), NilableHooksType)
          result.merge(hooks) if hooks&.any?
        end

        result
      end

      #
      # Body parsing by Content-Type:
      #   - multipart/form-data: form fields plus uploaded files wrapped in Rack::Multipart::UploadedFile
      #   - application/json: JSON object
      #   - anything else: JSON first, URL-encoded form data as fallback
      #
      # `rack.input` is only required to respond to `read`; Puma passes an IO or
      # StringIO, Falcon passes a Protocol::Rack::Input.
      #
      sig { params(env: RackEnvType).returns(T::Hash[String, T.untyped]) }
      private def parse_request_body(env)
        content_type = T.cast(env.fetch("CONTENT_TYPE", ""), String)
        body = env["rack.input"]
        return {} if body.nil? || !body.respond_to?(:read)

        return wrap_uploaded_files(Rack::Request.new(env).params) if content_type.include?("multipart/form-data")

        raw = read_bounded_body(body)
        return {} if raw.empty?

        return parse_json_object(raw) if content_type.include?("application/json")

        begin
          parsed = Oj.load(raw, Kirei::OJ_OPTIONS)
          return parsed if parsed.is_a?(Hash)
        rescue *JSON_PARSE_ERRORS
          # fall through to form data
        end

        T.cast(Rack::Request.new(env).params, T::Hash[String, T.untyped])
      end

      sig { params(body: T.untyped).returns(String) }
      private def read_bounded_body(body)
        limit = App.config.max_request_body_bytes
        raw = limit.nil? ? body.read : body.read(limit + 1)
        body.rewind if body.respond_to?(:rewind)
        raw = T.cast(raw || "", String)
        if !limit.nil? && raw.bytesize > limit
          raise RequestRejected.new(
            status: 413,
            code: "payload_too_large",
            detail: "Request body exceeds #{limit} bytes",
          )
        end

        raw
      end

      sig { params(raw: String).returns(T::Hash[String, T.untyped]) }
      private def parse_json_object(raw)
        parsed = Oj.load(raw, Kirei::OJ_OPTIONS)
        unless parsed.is_a?(Hash)
          raise RequestRejected.new(status: 400, code: "invalid_json_body", detail: "JSON body must be an object")
        end

        parsed
      rescue *JSON_PARSE_ERRORS => e
        raise RequestRejected.new(status: 400, code: "malformed_json", detail: e.message)
      end

      # Rack's multipart parser yields a Hash (symbol keys) per uploaded file; wrap it in a typed object.
      sig { params(params: T::Hash[String, T.untyped]).returns(T::Hash[String, T.untyped]) }
      private def wrap_uploaded_files(params)
        params.transform_values do |value|
          next value unless value.is_a?(Hash) && value.key?(:tempfile)

          Rack::Multipart::UploadedFile.new(
            io: value.fetch(:tempfile),
            content_type: value.fetch(:type, "application/octet-stream"),
            filename: value.fetch(:filename),
          )
        end
      end
    end
  end
end
# rubocop:enable Metrics
