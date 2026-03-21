# typed: false

require "spec_helper"

RSpec.describe Kirei::Routing::Base do
  let(:router) { Kirei::Routing::Router.instance }
  let(:original_routes) { router.routes.dup }

  before do
    router.routes.clear
    router.routes["GET /livez"] = Kirei::Routing::Route.new(
      verb: Kirei::Routing::Verb::GET,
      path: "/livez",
      controller: Dummy::HealthController,
      action: "livez",
    )
  end

  after { router.routes.replace(original_routes) }

  it "handles HEAD without invoking the controller", :aggregate_failures do
    app = DummyApp.new

    req_id = "req_test"

    env_get = Rack::MockRequest.env_for("/livez", method: "GET")
    env_get["REQUEST_PATH"] = "/livez"
    env_get["HTTP_HOST"] = "example.com"
    env_get["REMOTE_ADDR"] = "127.0.0.1"
    env_get["HTTP_X_REQUEST_ID"] = req_id

    status_get, headers_get, = app.call(env_get)

    env_head = Rack::MockRequest.env_for("/livez", method: "HEAD")
    env_head["REQUEST_PATH"] = "/livez"
    env_head["HTTP_HOST"] = "example.com"
    env_head["REMOTE_ADDR"] = "127.0.0.1"
    env_head["HTTP_X_REQUEST_ID"] = req_id

    allow(Dummy::HealthController).to receive(:new).and_call_original

    status_head, headers_head, body_head = app.call(env_head)

    expect(Dummy::HealthController).not_to have_received(:new)
    expect(status_head).to eq(status_get)
    expect(body_head).to eq([])
    expect(headers_head).to eq(headers_get)
  end
end
