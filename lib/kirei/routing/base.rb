# typed: strict
# frozen_string_literal: true

require_relative("middleware")

# rubocop:disable Metrics/AbcSize

module Kirei
  module Routing
    class Base
      include Middleware
      extend T::Sig

      sig { params(params: T::Hash[String, T.untyped]).void }
      def initialize(params: {})
        @router = T.let(Router.instance, Router)
        @params = T.let(params, T::Hash[String, T.untyped])
      end

      sig { returns(T::Hash[String, T.untyped]) }
      attr_reader :params

      sig { params(env: RackEnvType).returns(RackResponseType) }
      def call(env)
        http_verb = Router::Verb.deserialize(env.fetch("REQUEST_METHOD"))
        req_path = T.cast(env.fetch("REQUEST_PATH"), String)
        #
        # TODO: reject requests from unexpected hosts -> allow configuring allowed hosts in a `cors.rb` file
        #   ( offer a scaffold for this file )
        # -> use https://github.com/cyu/rack-cors ?
        #

        route = Router.instance.get(http_verb, req_path)
        return [404, {}, ["Not Found"]] if route.nil?

        params = case route.verb
                 when Router::Verb::GET
                   query = T.cast(env.fetch("QUERY_STRING"), String)
                   query.split("&").to_h do |p|
                     k, v = p.split("=")
                     k = T.cast(k, String)
                     [k, v]
                   end
                 when Router::Verb::POST, Router::Verb::PUT, Router::Verb::PATCH
                   # TODO: based on content-type, parse the body differently
                   #       build-in support for JSON & XML
                   body = T.cast(env.fetch("rack.input"), T.any(IO, StringIO))
                   res = Oj.load(body.read, Kirei::OJ_OPTIONS)
                   body.rewind # TODO: maybe don't rewind if we don't need to?
                   T.cast(res, T::Hash[String, T.untyped])
                 else
                   Logger.logger.warn("Unsupported HTTP verb: #{http_verb.serialize} send to #{req_path}")
                   {}
        end

        instance = route.controller.new(params: params)
        instance.public_send(route.action) # maybe have it return `returns(T.anything)`?
      end

      #
      # Kirei::App#render
      # * "status": defaults to 200
      # * "headers": defaults to an empty hash
      #
      sig do
        params(
          body: String,
          status: Integer,
          headers: T::Hash[String, String],
        ).returns(RackResponseType)
      end
      def render(body, status: 200, headers: {})
        # merge default headers
        # support a "type" to set content-type header? (or default to json, and users must set the header themselves for other types?)
        [
          status,
          headers,
          [body],
        ]
      end
    end
  end
end

# rubocop:enable Metrics/AbcSize
