# typed: strict
# frozen_string_literal: true

module Kirei::Routing
  Router.add_health_routes!

  Router.add_routes(
    [
      Route.new(
        verb: Verb::GET,
        path: "/airports",
        controller: Controllers::AirportsController,
        action: "index",
      ),
      Route.new(
        verb: Verb::GET,
        path: "/airports/:code",
        controller: Controllers::AirportsController,
        action: "show",
      ),
    ],
  )
end
