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
        routes[key]
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
