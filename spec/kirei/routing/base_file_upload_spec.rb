# typed: false

require "spec_helper"
require "tempfile"

RSpec.describe Kirei::Routing::Base do
  let(:router) { Kirei::Routing::Router.instance }
  let(:original_routes) { router.routes.dup }

  before do
    router.routes.clear
    router.routes["POST /uploads"] = Kirei::Routing::Route.new(
      verb: Kirei::Routing::Verb::POST,
      path: "/uploads",
      controller: Dummy::UploadsController,
      action: "create",
    )
  end

  after { router.routes.replace(original_routes) }

  it "passes a multipart file upload to the controller as an UploadedFile", :aggregate_failures do
    Tempfile.create(["hello", ".txt"]) do |tmp|
      tmp.write("hello kirei")
      tmp.flush

      upload = Rack::Multipart::UploadedFile.new(tmp.path, "text/plain")
      env = Rack::MockRequest.env_for(
        "/uploads",
        method: "POST",
        params: { "file" => upload, "description" => "greeting" },
      )
      env["REQUEST_PATH"] = "/uploads"
      env["HTTP_HOST"] = "example.com"
      env["REMOTE_ADDR"] = "127.0.0.1"

      status, _headers, body = DummyApp.new.call(env)

      expect(status).to eq(200)
      data = JSON.parse(body.join)
      expect(data["filename"]).to eq(File.basename(tmp.path))
      expect(data["content_type"]).to eq("text/plain")
      expect(data["content"]).to eq("hello kirei")
      expect(data["description"]).to eq("greeting")
    end
  end
end
