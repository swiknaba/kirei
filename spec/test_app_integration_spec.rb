# typed: false

require "spec_helper"
require "net/http"
require "json"
require "socket"

RSpec.describe "TestApp integration" do # rubocop:disable RSpec/DescribeClass
  app_dir = File.expand_path("test_app", __dir__)
  gemfile = File.join(app_dir, "Gemfile")

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    env = { "BUNDLE_GEMFILE" => gemfile, "RACK_ENV" => "test" }
    @pid = Process.spawn(env, "bundle", "exec", "puma", "-b", "tcp://0.0.0.0:9292", chdir: app_dir, out: File::NULL, err: File::NULL)

    10.times do
      TCPSocket.new("0.0.0.0", 9292).close
      break
    rescue Errno::ECONNREFUSED
      sleep 1
    end
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    Process.kill("TERM", @pid) # rubocop:disable RSpec/InstanceVariable
    Process.wait(@pid) # rubocop:disable RSpec/InstanceVariable
  rescue StandardError
    nil
  end

  it "responds with version key" do # rubocop:disable RSpec/ExampleLength
    uri = URI("http://0.0.0.0:9292/livez")
    ENV["http_proxy"] = nil
    ENV["https_proxy"] = nil
    ENV["HTTP_PROXY"] = nil
    ENV["HTTPS_PROXY"] = nil
    res = Net::HTTP.get(uri)
    data = JSON.parse(res)
    expect(data).to include("version")
  end
end
