# typed: strict
# frozen_string_literal: true

module Kirei::Routing
  Router.add_routes(
    [
      Router::Route.new(
        verb: Router::Verb::GET,
        path: "/livez",
        controller: Controllers::Health,
        action: "livez",
      ),
      Router::Route.new(
        verb: Router::Verb::GET,
        path: "/airports",
        controller: Controllers::AirportsController,
        action: "index",
      ),
    ],
  )
end
