# typed: strict
# frozen_string_literal: true

include(Kirei::Routing)

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
      controller: Controllers::Airports,
      action: "index",
    ),
  ],
)
