# typed: false

require "spec_helper"

RSpec.describe Kirei::Routing::Router do
  let(:router) { described_class.instance }

  after { router.current_env = nil }

  it "scopes current_env to the fiber, so concurrent requests do not share it", :aggregate_failures do
    router.current_env = { "owner" => "root" }

    first = Fiber.new do
      router.current_env = { "owner" => "first" }
      Fiber.yield router.current_env
      router.current_env
    end
    second = Fiber.new do
      router.current_env = { "owner" => "second" }
      router.current_env
    end

    expect(first.resume).to eq({ "owner" => "first" })
    expect(second.resume).to eq({ "owner" => "second" })
    expect(first.resume).to eq({ "owner" => "first" })
    expect(router.current_env).to eq({ "owner" => "root" })
  end
end
