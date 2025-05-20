# typed: strict
# frozen_string_literal: true

require("singleton")

module Kirei
  module Routing
    #
    # Usage:
    #
    # Router.add_routes([
    #   Route.new(
    #     verb: Verb::GET,
    #     path: "/livez",
    #     controller: Controllers::HealthController,
    #     action: "livez",
    #   ),
    # ])
    #
    class Router
      extend T::Sig
      include ::Singleton

      RoutesHash = T.type_alias do
        T::Hash[String, Route]
      end

      sig { returns(T.nilable(T::Hash[String, T.untyped])) }
      attr_accessor :current_env

      sig { void }
      def initialize
        @routes = T.let({}, RoutesHash)
      end

      sig { returns(RoutesHash) }
      attr_reader :routes

      sig do
        params(
          verb: Verb,
          path: String,
        ).returns(T.nilable(Route))
      end
      def get(verb, path)
        key = "#{verb.serialize} #{path}"
        route = routes[key]

        if route.nil? && verb == Verb::HEAD
          key = "#{Verb::GET.serialize} #{path}"
          route = routes[key]
        end

        route
      end

      sig { params(routes: T::Array[Route]).void }
      def self.add_routes(routes)
        routes.each do |route|
          key = "#{route.verb.serialize} #{route.path}"
          instance.routes[key] = route
        end
      end
    end
  end
end
