# typed: false

require "spec_helper"
require "net/http"
require "json"
require "socket"

RSpec.describe "TestApp integration" do # rubocop:disable RSpec/DescribeClass
  app_dir = File.expand_path("test_app", __dir__)
  gemfile = File.join(app_dir, "Gemfile")

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    env = {
      "BUNDLE_GEMFILE" => gemfile,
      "RACK_ENV" => "test",
      "PORT" => "9292"  # Explicitly set port
    }
    log_file = File.join(app_dir, "puma.log")
    @pid = Process.spawn(env, "bundle", "exec", "puma", "-b", "tcp://127.0.0.1:9292", chdir: app_dir, out: log_file, err: log_file)

    # Wait for server to be ready with increased timeout and better error handling
    server_started = false
    30.times do |i|
      begin
        TCPSocket.new("127.0.0.1", 9292).close
        server_started = true
        break
      rescue Errno::ECONNREFUSED
        if i == 29 # Last attempt
          puts "Server failed to start. Check #{log_file} for details:"
          puts File.read(log_file) if File.exist?(log_file)
          raise "Server failed to start after 30 seconds"
        end
        sleep 1
      end
    end

    raise "Server failed to start" unless server_started
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    Process.kill("TERM", @pid) # rubocop:disable RSpec/InstanceVariable
    Process.wait(@pid) # rubocop:disable RSpec/InstanceVariable
  rescue StandardError
    nil
  end

  it "responds with version key" do # rubocop:disable RSpec/ExampleLength
    uri = URI("http://127.0.0.1:9292/livez")
    ENV["http_proxy"] = nil
    ENV["https_proxy"] = nil
    ENV["HTTP_PROXY"] = nil
    ENV["HTTPS_PROXY"] = nil

    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 5
    http.open_timeout = 5

    begin
      response = http.get(uri.path)
      expect(response.code).to eq("200")
      data = JSON.parse(response.body)
      expect(data).to include("version")
    rescue => e
      puts "Request failed. Server logs:"
      puts File.read(File.join(app_dir, "puma.log")) if File.exist?(File.join(app_dir, "puma.log"))
      raise e
    end
  end
end
