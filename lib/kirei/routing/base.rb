# typed: strict
# frozen_string_literal: true

# rubocop:disable Metrics/all

module Kirei
  module Routing
    class Base
      extend T::Sig

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

        http_verb = Verb.deserialize(env.fetch("REQUEST_METHOD"))
        req_path = T.cast(env.fetch("REQUEST_PATH"), String)
        #
        # TODO: reject requests from unexpected hosts -> allow configuring allowed hosts in a `cors.rb` file
        #   ( offer a scaffold for this file )
        # -> use https://github.com/cyu/rack-cors ?
        #

        route = router.get(http_verb, req_path)
        return [404, {}, ["Not Found"]] if route.nil?

        params = case route.verb
                 when Verb::GET
                   query = T.cast(env.fetch("QUERY_STRING"), String)
                   query.split("&").to_h do |p|
                     k, v = p.split("=")
                     k = T.cast(k, String)
                     [k, v]
                   end
                 when Verb::POST, Verb::PUT, Verb::PATCH
                   # TODO: based on content-type, parse the body differently
                   #       build-in support for JSON & XML
                   body = T.cast(env.fetch("rack.input"), T.any(IO, StringIO))
                   res = Oj.load(body.read, Kirei::OJ_OPTIONS)
                   body.rewind # TODO: maybe don't rewind if we don't need to?
                   T.cast(res, T::Hash[String, T.untyped])
                 else
                   Logging::Logger.logger.warn("Unsupported HTTP verb: #{http_verb.serialize} send to #{req_path}")
                   {}
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

        status, headers, response_body = T.cast(
          controller.new(params: params).public_send(route.action),
          RackResponseType,
        )

        after_hooks = collect_hooks(controller, :after_hooks)
        run_hooks(after_hooks)

        headers["X-Request-Id"] ||= req_id

        default_headers.each do |header_name, default_value|
          headers[header_name] ||= default_value
        end

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
            level: Kirei::Logging::Level::INFO,
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
        # "Access-Control-Allow-Origin": the user should set that, see comment about "cors" above
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
