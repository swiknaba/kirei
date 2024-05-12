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
    #     verb: Kirei::Router::Verb::GET,
    #     path: "/livez",
    #     controller: Controllers::HealthController,
    #     action: "livez",
    #   ),
    # ])
    #
    class Router
      extend T::Sig
      include ::Singleton

      class Verb < T::Enum
        enums do
          # idempotent
          GET     = new("GET")
          # non-idempotent
          POST    = new("POST")
          # idempotent
          PUT     = new("PUT")
          # non-idempotent
          PATCH   = new("PATCH")
          # non-idempotent
          DELETE  = new("DELETE")
          # idempotent
          HEAD    = new("HEAD")
          # idempotent
          OPTIONS = new("OPTIONS")
          # idempotent
          TRACE   = new("TRACE")
          # non-idempotent
          CONNECT = new("CONNECT")
        end
      end

      class Route < T::Struct
        const :verb, Verb
        const :path, String
        const :controller, T.class_of(Controller)
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
