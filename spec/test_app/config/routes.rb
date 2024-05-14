# typed: strict
# frozen_string_literal: true

module Kirei::Routing
  Router.add_routes(
    [
      Route.new(
        verb: Verb::GET,
        path: "/livez",
        controller: Controllers::Health,
        action: "livez",
      ),
      Route.new(
        verb: Verb::GET,
        path: "/airports",
        controller: Controllers::AirportsController,
        action: "index",
      ),
    ],
  )
end
