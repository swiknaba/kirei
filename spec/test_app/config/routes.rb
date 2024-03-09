# typed: strict
# frozen_string_literal: true

Kirei::Router.add_routes([
  # Route.new(
  #   method: "GET",
  #   path: "/livez",
  #   controller: Controllers::HealthController,
  #   action: "livez",
  # ),
  Kirei::Router::Route.new(
    method: "GET",
    path: "/airports",
    controller: Controllers::AirportsController,
    action: "index",
  ),
])
