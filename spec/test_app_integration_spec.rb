# typed: false

require "spec_helper"
require "net/http"
require "uri"

RSpec.describe "TestApp integration" do # rubocop:disable RSpec/DescribeClass
  let(:port) { 9292 }
  let(:server_url) { "http://localhost:#{port}" }

  around do |example|
    pid = fork do
      require_relative("test_app/app")
      Rack::Handler::Puma.run(
        TestApp,
        Port: port,
        Host: "localhost",
        Silent: true,
      )
    end

    sleep 1 # puma boots the app

    begin
      example.run
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end

  it "server boots and health check is successful" do
    uri = URI("#{server_url}/livez")
    response = Net::HTTP.get_response(uri)

    expect(response.code).to eq("200")
    data = JSON.parse(response.body)
    expect(data).to include("version")
  end
end
