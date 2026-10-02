# typed: false

require "spec_helper"

RSpec.describe Kirei::Routing::Base do
  subject(:base) { Dummy::HealthController.new }

  describe "#render_json" do
    it "passes through a String unchanged" do
      json_string = '{"ok":true}'
      status, _headers, body = base.render_json(json_string)

      expect(status).to eq(200)
      expect(body).to eq([json_string])
    end

    it "serializes a Hash via Oj.dump" do
      data = { "ok" => true }
      status, _headers, body = base.render_json(data, status: 201)

      expect(status).to eq(201)
      expect(body).to eq([Oj.dump(data, Kirei::OJ_OPTIONS)])
    end

    it "serializes an Array via Oj.dump" do
      data = [{ "id" => 1 }, { "id" => 2 }]
      _status, _headers, body = base.render_json(data)

      expect(body).to eq([Oj.dump(data, Kirei::OJ_OPTIONS)])
    end

    it "calls #serialize on objects that respond to it (T::Struct)" do
      struct = Kirei::Errors::JsonApiError.new(code: "not_found", detail: "Resource not found")
      _status, _headers, body = base.render_json(struct)

      parsed = Oj.load(body.first, Kirei::OJ_OPTIONS)
      expect(parsed).to eq({ "code" => "not_found", "detail" => "Resource not found" })
    end

    it "passes custom headers through to the response" do
      _status, headers, _body = base.render_json("{}", headers: { "X-Custom" => "yes" })

      expect(headers).to eq({ "X-Custom" => "yes" })
    end

    it "raises ArgumentError for unsupported types" do
      expect { base.render_json(42) }.to raise_error(
        ArgumentError,
        /render_json expects a String, Hash, Array, or an object responding to #serialize/,
      )
    end
  end

  describe "#render_error" do
    it "wraps errors in JSON:API format with default 422 status" do
      errors = [
        Kirei::Errors::JsonApiError.new(code: "invalid", detail: "is too short"),
      ]

      status, _headers, body = base.render_error(errors)
      parsed = Oj.load(body.first, Kirei::OJ_OPTIONS)

      expect(status).to eq(422)
      expect(parsed).to eq({
                             "errors" => [
                               { "code" => "invalid", "detail" => "is too short" },
                             ],
                           })
    end

    it "supports custom status and headers" do
      errors = [
        Kirei::Errors::JsonApiError.new(code: "not_found", detail: "not found"),
      ]

      status, headers, _body = base.render_error(errors, status: 404, headers: { "X-Error" => "true" })

      expect(status).to eq(404)
      expect(headers).to eq({ "X-Error" => "true" })
    end

    it "serializes multiple errors" do
      errors = [
        Kirei::Errors::JsonApiError.new(code: "invalid", detail: "too short"),
        Kirei::Errors::JsonApiError.new(code: "blank", detail: "can't be blank"),
      ]

      _status, _headers, body = base.render_error(errors)
      parsed = Oj.load(body.first, Kirei::OJ_OPTIONS)

      expect(parsed["errors"].length).to eq(2)
      expect(parsed["errors"].map { |e| e["code"] }).to eq(%w[invalid blank])
    end
  end
end
