# typed: false

require "spec_helper"

RSpec.describe Kirei::Controllers::Health do
  subject(:controller) { described_class.new }

  let(:mock_env) do
    {
      "HTTP_HOST" => "localhost:3000",
      "SERVER_PORT" => "3000",
      "rack.url_scheme" => "http",
    }
  end

  before do
    router = Kirei::Routing::Router.instance
    router.current_env = mock_env
  end

  describe "#livez" do
    it "returns 200 with application metadata" do
      status, _headers, body = controller.livez

      expect(status).to eq(200)
      data = Oj.load(body.first, Kirei::OJ_OPTIONS)
      expect(data["status"]).to eq("ok")
      expect(data).to include("version", "app_name", "environment", "req_host", "req_port", "req_ssl")
    end
  end

  describe "#readyz" do
    context "when DB is reachable" do
      before do
        mock_db = double("db") # rubocop:disable RSpec/VerifiedDoubles
        allow(mock_db).to receive(:execute).with("SELECT 1")
        allow(Kirei::App).to receive(:raw_db_connection).and_return(mock_db)
      end

      it "returns 200 with ok status" do
        status, _headers, body = controller.readyz

        expect(status).to eq(200)
        data = Oj.load(body.first, Kirei::OJ_OPTIONS)
        expect(data).to eq("status" => "ok")
      end
    end

    context "when DB is unreachable" do
      before do
        mock_db = double("db") # rubocop:disable RSpec/VerifiedDoubles
        allow(mock_db).to receive(:execute).with("SELECT 1").and_raise(Sequel::DatabaseConnectionError, "connection refused")
        allow(Kirei::App).to receive(:raw_db_connection).and_return(mock_db)
      end

      it "returns 503 with unavailable status" do
        status, _headers, body = controller.readyz

        expect(status).to eq(503)
        data = Oj.load(body.first, Kirei::OJ_OPTIONS)
        expect(data["status"]).to eq("unavailable")
        expect(data["reason"]).to include("connection refused")
      end
    end
  end

  describe "#healthz" do
    it "delegates to livez and returns 200" do
      status, _headers, body = controller.healthz

      expect(status).to eq(200)
      data = Oj.load(body.first, Kirei::OJ_OPTIONS)
      expect(data["status"]).to eq("ok")
    end
  end
end
