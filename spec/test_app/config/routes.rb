# typed: strict
# frozen_string_literal: true

module Kirei::Routing
  Router.add_health_routes!

  Router.add_routes(
    [
      Route.new(
        verb: Verb::GET,
        path: "/airports",
        controller: Airports::Controllers::AirportsController,
        action: "index",
      ),
      Route.new(
        verb: Verb::GET,
        path: "/airports/:code",
        controller: Airports::Controllers::AirportsController,
        action: "show",
      ),
      Route.new(
        verb: Verb::GET,
        path: "/flights",
        controller: Flights::Controllers::FlightsController,
        action: "index",
      ),
    ],
  )
end
