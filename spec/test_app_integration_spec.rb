# typed: false

require "spec_helper"
require "rack/test"
require "json"

RSpec.describe "TestApp integration" do # rubocop:disable RSpec/DescribeClass
  include Rack::Test::Methods

  def app
    require_relative("test_app/app")
    TestApp.new
  end

  it "server boots and health check is successful" do
    get "/livez"
    expect(last_response).to have_http_status(:ok)
    data = JSON.parse(last_response.body)
    expect(data).to include("version")
  end
end
