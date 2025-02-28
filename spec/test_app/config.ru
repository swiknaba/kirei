# typed: false
# frozen_string_literal: true

require_relative("app")

# Load middlewares here
use(Rack::Reloader, 0) if TestApp.environment == "development"

# add more custom middlewares here, e.g.
use(Middleware::Example)

# Launch the app
run(TestApp.new)

# "use" all controllers
# store all routes in a global variable to render (localhost only)
# put "booted" statement
