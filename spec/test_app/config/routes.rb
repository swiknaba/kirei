# typed: strict
# frozen_string_literal: true

Kirei::Router.add_routes([
  Kirei::Router::Route.new(
    verb: "GET",
    path: "/livez",
    controller: Controllers::Health,
    action: "livez",
  ),
  Kirei::Router::Route.new(
    verb: "GET",
    path: "/airports",
    controller: Controllers::Airports,
    action: "index",
  ),
])
