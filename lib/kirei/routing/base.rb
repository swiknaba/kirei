# typed: strict
# frozen_string_literal: true

# rubocop:disable Metrics/all

module Kirei
  module Routing
    class Base
      extend T::Sig

      NOT_FOUND = T.let([404, {}, ["Not Found"]], RackResponseType) # rubocop:disable Style/MutableConstant

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
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
        status = 500 # we use it in the "ensure" block, so we need to define early (Sorbet doesn't like `status ||= 418`)

        http_verb = Verb.deserialize(env.fetch("REQUEST_METHOD"))
        req_path = T.cast(env.fetch("REQUEST_PATH"), String)
        #
        # TODO: reject requests from unexpected hosts -> allow configuring allowed hosts in a `cors.rb` file
        #   ( offer a scaffold for this file )
        # -> use https://github.com/cyu/rack-cors ?
        #

        lookup_verb = http_verb == Verb::HEAD ? Verb::GET : http_verb
        route = router.get(lookup_verb, req_path)
        return NOT_FOUND if route.nil?

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
                   content_type = T.cast(env.fetch("CONTENT_TYPE", ""), String)

                   if content_type.include?("multipart/form-data")
                     rack_request = Rack::Request.new(env)
                     T.cast(rack_request.params, T::Hash[String, T.untyped])
                   elsif content_type.include?("application/json")
                     body = T.cast(env.fetch("rack.input"), T.any(IO, StringIO))
                     res = Oj.load(body.read, Kirei::OJ_OPTIONS)
                     body.rewind # TODO: maybe don't rewind if we don't need to?
                     T.cast(res, T::Hash[String, T.untyped])
                   else
                     body = T.cast(env.fetch("rack.input"), T.any(IO, StringIO))
                     begin
                       res = Oj.load(body.read, Kirei::OJ_OPTIONS)
                       body.rewind
                       T.cast(res, T::Hash[String, T.untyped])
                     rescue Oj::ParseError
                       # If JSON parsing fails, use form data parsing
                       body.rewind
                       rack_request = Rack::Request.new(env)
                       T.cast(rack_request.params, T::Hash[String, T.untyped])
                     end
                   end
                 when Verb::HEAD, Verb::DELETE, Verb::OPTIONS, Verb::TRACE, Verb::CONNECT
                   {}
                 else
                   T.absurd(http_verb)
        end

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

        statsd_timing_tags = {
          "controller" => controller.name,
          "route" => route.action,
        }
        Logging::Metric.inject_defaults(statsd_timing_tags)

        status, headers, response_body = case http_verb
                                         when Verb::HEAD, Verb::OPTIONS, Verb::TRACE, Verb::CONNECT
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
      ensure
        stop = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
        if start # early return for 404
          latency_in_ms = stop - start
          ::StatsD.measure("request", latency_in_ms, tags: statsd_timing_tags)

          Kirei::Logging::Logger.call(
            level: status >= 500 ? Kirei::Logging::Level::ERROR : Kirei::Logging::Level::INFO,
            label: "Request Finished",
            meta: { "response.body" => response_body, "response.latency_in_ms" => latency_in_ms },
          )
        end

        # reset global variables after the request has been served
        # and after all "after" hooks have run to avoid leaking
        Thread.current[:enduser_id] = nil
        Thread.current[:request_id] = nil
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
    end
  end
end

# rubocop:enable Metrics/all
