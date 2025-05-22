# typed: false

require "spec_helper"
require "rack/test"
require "json"

RSpec.describe "TestApp integration" do # rubocop:disable RSpec/DescribeClass
  include Rack::Test::Methods

  app_dir = File.expand_path("test_app", __dir__)
  File.join(app_dir, "Gemfile")

  def app
    # Ensure we're in the right environment
    # ENV["BUNDLE_GEMFILE"] = gemfile
    # ENV["RACK_ENV"] = "test"

    # Load the test app directly
    require_relative "test_app/app"

    # The app is already configured in app.rb, we just need to return it
    TestApp
  end

  it "server boots and health check is successful" do
    get "/livez"
    expect(last_response).to have_http_status(:ok)
    data = JSON.parse(last_response.body)
    expect(data).to include("version")
  end
end
