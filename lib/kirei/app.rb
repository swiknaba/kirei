# typed: strict
# frozen_string_literal: true

require_relative("middleware")

module Kirei
  class App
    include Middleware
    extend T::Sig

    sig { params(params: T::Hash[String, T.untyped]).void }
    def initialize(params: {})
      @router = T.let(Router.instance, Router)
      @params = T.let(params, T::Hash[String, T.untyped])
    end

    sig { returns(T::Hash[String, T.untyped]) }
    attr_reader :params

    # TODO: maybe just `.void`? (so users can just `void` the method instead of `returns(RackResponseType)`)
    sig { params(env: RackEnvType).returns(RackResponseType) }
    def call(env)
      http_verb = T.cast(env.fetch("REQUEST_METHOD"), String)
      req_path = T.cast(env.fetch("REQUEST_PATH"), String)
      req_host, req_port = T.cast(env.fetch("HTTP_HOST"), String).split(":")

      route = Router.instance.get(http_verb, req_path)
      return [404, {}, ["Not Found"]] if route.nil?

      params = if route.verb == 'GET'
        query = T.cast(env.fetch("QUERY_STRING"), String)
        query.split("&").to_h do |p|
          k, v = p.split("=")
          k = T.cast(k, String)
          [k, v]
        end
      else
        # TODO: based on content-type, parse the body differently
        #       build-in support for JSON & XML
        body = T.cast(env.fetch("rack.input"), T.any(IO, StringIO))
        res = Oj.load(body.read, Kirei::OJ_OPTIONS)
        body.rewind # TODO: maybe don't rewind if we don't need to?
        res
      end

      instance = route.controller.new(params: params)
      instance.public_send(route.action)
    end
  end
end
