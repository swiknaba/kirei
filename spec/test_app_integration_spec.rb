# typed: false

require "spec_helper"
require "net/http"
require "uri"
require "socket"

RSpec.describe "TestApp integration", :integration do # rubocop:disable RSpec/DescribeClass
  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    app_dir = File.expand_path("test_app", __dir__)
    env = { "BUNDLE_GEMFILE" => File.join(app_dir, "Gemfile"), "RACK_ENV" => "test" }
    @pid = Process.spawn(
      env,
      "bundle", "exec", "puma",
      "-b", "tcp://127.0.0.1:9294",
      chdir: app_dir,
      out: File::NULL,
      err: File::NULL
    )

    start_time = Time.now
    while Time.now - start_time < 10
      begin
        TCPSocket.new("127.0.0.1", 9294).close
        break
      rescue Errno::ECONNREFUSED
        sleep 0.1
      end
    end
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    Process.kill("TERM", @pid) # rubocop:disable RSpec/InstanceVariable
    Process.wait(@pid) # rubocop:disable RSpec/InstanceVariable
  rescue StandardError
    nil
  end

  # Clear any proxy settings that might interfere
  before do
    ENV["http_proxy"] = nil
    ENV["https_proxy"] = nil
    ENV["HTTP_PROXY"] = nil
    ENV["HTTPS_PROXY"] = nil
  end

  it "server boots and livez health check is successful" do
    uri = URI("http://127.0.0.1:9294/livez")

    response = Net::HTTP.get_response(uri)
    expect(response.code).to eq("200")
    data = JSON.parse(response.body)
    expect(data["status"]).to eq("ok")
    expect(data).to include("version", "app_name", "environment")
  end

  it "readyz health check is successful" do
    uri = URI("http://127.0.0.1:9294/readyz")

    response = Net::HTTP.get_response(uri)
    expect(response.code).to eq("200")
    data = JSON.parse(response.body)
    expect(data).to eq("status" => "ok")
  end

  it "healthz health check is successful (deprecated alias)" do
    uri = URI("http://127.0.0.1:9294/healthz")

    response = Net::HTTP.get_response(uri)
    expect(response.code).to eq("200")
    data = JSON.parse(response.body)
    expect(data).to include("status" => "ok")
  end
end
