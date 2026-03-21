# typed: strict
# frozen_string_literal: true

# rubocop:disable Metrics/all

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

      ResolveResult = T.type_alias do
        T.nilable([Route, T::Hash[String, String]])
      end

      sig { returns(T.nilable(T::Hash[String, T.untyped])) }
      attr_accessor :current_env

      sig { void }
      def initialize
        @routes = T.let({}, RoutesHash)
        @dynamic_routes = T.let([], T::Array[Route])
      end

      sig { returns(RoutesHash) }
      attr_reader :routes

      sig { returns(T::Array[Route]) }
      attr_reader :dynamic_routes

      # Looks up a static route by exact verb + path match. O(1).
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

      # Resolves a request to a route and extracted path parameters.
      # Tries static O(1) lookup first, then falls back to dynamic segment matching.
      sig do
        params(
          verb: Verb,
          path: String,
        ).returns(ResolveResult)
      end
      def resolve(verb, path)
        static_route = get(verb, path)
        return [static_route, {}] unless static_route.nil?

        match_dynamic(verb, path)
      end

      sig { params(routes: T::Array[Route]).void }
      def self.add_routes(routes)
        routes.each do |route|
          if route.dynamic?
            instance.dynamic_routes << route
          else
            key = "#{route.verb.serialize} #{route.path}"
            instance.routes[key] = route
          end
        end
      end

      # Matches a request path against registered dynamic routes.
      # Returns [Route, extracted_params] or nil.
      sig do
        params(
          verb: Verb,
          path: String,
        ).returns(ResolveResult)
      end
      private def match_dynamic(verb, path)
        request_segments = path.split("/", -1)

        dynamic_routes.each do |route|
          next unless route.verb == verb

          route_segments = route.segments
          next unless route_segments.length == request_segments.length

          path_params = T.let({}, T::Hash[String, String])
          matched = T.let(true, T::Boolean)

          route_segments.each_with_index do |route_seg, idx|
            req_seg = T.must(request_segments[idx])

            if route_seg.start_with?(":")
              param_name = T.must(route_seg[1..])
              path_params[param_name] = req_seg
            elsif route_seg != req_seg
              matched = false
              break
            end
          end

          return [route, path_params] if matched
        end

        nil
      end
    end
  end
end

# rubocop:enable Metrics/all
