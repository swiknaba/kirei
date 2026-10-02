# typed: false

require "spec_helper"

# Mimics Protocol::Rack::Input (Falcon): readable and rewindable, but neither IO nor StringIO.
class FalconLikeInput
  def initialize(content)
    @io = StringIO.new(content)
  end

  def read(length = nil) = @io.read(length)
  def rewind = @io.rewind
end

RSpec.describe Kirei::Routing::Base do
  let(:router) { Kirei::Routing::Router.instance }
  let(:original_routes) { router.routes.dup }
  let(:app) { DummyApp.new }
  let(:config) { Kirei::App.config }

  before do
    router.routes.clear
    router.routes["POST /echo"] = Kirei::Routing::Route.new(
      verb: Kirei::Routing::Verb::POST,
      path: "/echo",
      controller: Dummy::EchoController,
      action: "create",
    )
    router.routes["POST /uploads"] = Kirei::Routing::Route.new(
      verb: Kirei::Routing::Verb::POST,
      path: "/uploads",
      controller: Dummy::UploadsController,
      action: "create",
    )
  end

  after do
    router.routes.replace(original_routes)
    config.max_request_body_bytes = nil
  end

  define_method(:post_env) do |body, content_type: "application/json", request_path: true|
    env = Rack::MockRequest.env_for("/echo", method: "POST", input: body)
    env["CONTENT_TYPE"] = content_type
    env["REQUEST_PATH"] = "/echo" if request_path
    env["HTTP_HOST"] = "example.com"
    env["REMOTE_ADDR"] = "127.0.0.1"
    env
  end

  define_method(:error_code) { |body| Oj.load(body.first)["errors"].first["code"] }

  it "routes by PATH_INFO when the server sets no REQUEST_PATH" do
    status, _headers, body = app.call(post_env('{"a":1}', request_path: false))

    expect(status).to eq(200)
    expect(Oj.load(body.first)).to eq({ "a" => 1 })
  end

  it "reads a rack.input that is neither IO nor StringIO" do
    env = post_env(nil)
    env["rack.input"] = FalconLikeInput.new('{"from":"falcon"}')

    status, _headers, body = app.call(env)

    expect(status).to eq(200)
    expect(Oj.load(body.first)).to eq({ "from" => "falcon" })
  end

  it "returns 400 for malformed JSON", :aggregate_failures do
    status, headers, body = app.call(post_env("{not json"))

    expect(status).to eq(400)
    expect(headers["Content-Type"]).to include("application/json")
    expect(error_code(body)).to eq("malformed_json")
  end

  it "returns 400 when the JSON body is not an object" do
    status, _headers, body = app.call(post_env("[1,2]"))

    expect(status).to eq(400)
    expect(error_code(body)).to eq("invalid_json_body")
  end

  it "has no body limit by default" do
    status, = app.call(post_env(Oj.dump({ "big" => "x" * 200_000 })))

    expect(status).to eq(200)
  end

  it "returns 413 above max_request_body_bytes and accepts bodies at the limit", :aggregate_failures do
    config.max_request_body_bytes = 32
    at_limit = Oj.dump({ "k" => "x" * 24 })
    expect(at_limit.bytesize).to eq(32)

    status, = app.call(post_env(at_limit))
    expect(status).to eq(200)

    status, _headers, body = app.call(post_env(Oj.dump({ "k" => "x" * 26 })))
    expect(status).to eq(413)
    expect(error_code(body)).to eq("payload_too_large")
  end

  it "does not apply the body limit to multipart uploads" do
    config.max_request_body_bytes = 16
    Tempfile.create(["big", ".txt"]) do |tmp|
      tmp.write("x" * 1_000)
      tmp.flush
      upload = Rack::Multipart::UploadedFile.new(tmp.path, "text/plain")
      env = Rack::MockRequest.env_for("/uploads", method: "POST", params: { "file" => upload })
      env["HTTP_HOST"] = "example.com"
      env["REMOTE_ADDR"] = "127.0.0.1"

      status, _headers, body = app.call(env)

      expect(status).to eq(200)
      expect(JSON.parse(body.join)["content"].bytesize).to eq(1_000)
    end
  end

  it "clears the router env after the request" do
    app.call(post_env("{}"))

    expect(router.current_env).to be_nil
  end
end
