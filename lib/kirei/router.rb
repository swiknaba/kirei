# typed: strict
# frozen_string_literal: true

require("singleton")

module Kirei
  class Router
    extend T::Sig
    include ::Singleton

    class Route < T::Struct
      const :verb, String
      const :path, String
      const :controller, T.class_of(BaseController)
      const :action, String
    end

    RoutesHash = T.type_alias do
      T::Hash[String, Route]
    end

    sig { void }
    def initialize
      @routes = T.let({}, RoutesHash)
    end

    sig { returns(RoutesHash) }
    attr_reader :routes

    sig do
      params(
        verb: String,
        path: String,
      ).returns(T.nilable(Route))
    end
    def get(verb, path)
      key = "#{verb} #{path}"
      routes[key]
    end

    sig { params(routes: T::Array[Route]).void }
    def self.add_routes(routes)
      routes.each do |route|
        key = "#{route.verb} #{route.path}"
        instance.routes[key] = route
      end
    end
  end
end
