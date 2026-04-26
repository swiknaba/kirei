# typed: false

require "spec_helper"

RSpec.describe Kirei::Routing::Base do
  let(:router) { Kirei::Routing::Router.instance }
  let(:original_routes) { router.routes.dup }
  let(:app) { DummyApp.new }

  before do
    router.routes.clear
    router.routes["GET /raises"] = Kirei::Routing::Route.new(
      verb: Kirei::Routing::Verb::GET,
      path: "/raises",
      controller: Dummy::RaisingController,
      action: "blow_up",
    )
  end

  after { router.routes.replace(original_routes) }

  define_method(:build_env) do |path, method: "GET"|
    env = Rack::MockRequest.env_for(path, method: method)
    env["REQUEST_PATH"] = path
    env["HTTP_HOST"] = "example.com"
    env["REMOTE_ADDR"] = "127.0.0.1"
    env["HTTP_X_REQUEST_ID"] = "req_test_exception"
    env
  end

  it "returns a JSON:API 500 response for unhandled exceptions", :aggregate_failures do
    status, headers, body = app.call(build_env("/raises"))

    expect(status).to eq(500)
    expect(headers["Content-Type"]).to include("application/json")

    parsed = Oj.load(body.first)
    expect(parsed).to have_key("errors")
    expect(parsed["errors"].length).to eq(1)
    expect(parsed["errors"].first["code"]).to eq("internal_server_error")
  end

  it "includes backtrace in development mode", :aggregate_failures do
    allow(Kirei::App).to receive(:environment).and_return("development")

    _, _, body = app.call(build_env("/raises"))

    parsed = Oj.load(body.first)
    detail = parsed["errors"].first["detail"]
    expect(detail).to include("RuntimeError")
    expect(detail).to include("boom")
  end

  it "hides backtrace in production mode", :aggregate_failures do
    allow(Kirei::App).to receive(:environment).and_return("production")

    _, _, body = app.call(build_env("/raises"))

    parsed = Oj.load(body.first)
    detail = parsed["errors"].first["detail"]
    expect(detail).to eq("An unexpected error occurred")
  end
end
