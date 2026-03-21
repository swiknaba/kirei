# typed: false

require "spec_helper"

module RouterSpecDummy
  class DummyController < Kirei::Controller
    sig { returns(T.anything) }
    def index
      render(Oj.dump({ "ok" => true }))
    end

    sig { returns(T.anything) }
    def show
      render(Oj.dump(params))
    end
  end
end

RSpec.describe Kirei::Routing::Router do
  let(:router) { described_class.instance }
  let(:original_routes) { router.routes.dup }
  let(:original_dynamic_routes) { router.dynamic_routes.dup }

  before do
    router.routes.clear
    router.dynamic_routes.clear
  end

  after do
    router.routes.clear
    router.dynamic_routes.clear
    original_routes.each { |k, v| router.routes[k] = v }
    original_dynamic_routes.each { |r| router.dynamic_routes << r }
  end

  describe "#resolve" do
    context "with static routes" do
      before do
        described_class.add_routes([
                                     Kirei::Routing::Route.new(
                                       verb: Kirei::Routing::Verb::GET,
                                       path: "/livez",
                                       controller: RouterSpecDummy::DummyController,
                                       action: "index",
                                     ),
                                   ])
      end

      it "returns the route with empty path params" do
        result = router.resolve(Kirei::Routing::Verb::GET, "/livez")
        expect(result).not_to be_nil
        route, path_params = result
        expect(route.path).to eq("/livez")
        expect(path_params).to eq({})
      end

      it "returns nil for unregistered paths" do
        result = router.resolve(Kirei::Routing::Verb::GET, "/unknown")
        expect(result).to be_nil
      end
    end

    context "with dynamic routes" do
      before do
        described_class.add_routes([
                                     Kirei::Routing::Route.new(
                                       verb: Kirei::Routing::Verb::GET,
                                       path: "/airports/:code",
                                       controller: RouterSpecDummy::DummyController,
                                       action: "show",
                                     ),
                                   ])
      end

      it "extracts a single path parameter" do
        result = router.resolve(Kirei::Routing::Verb::GET, "/airports/JFK")
        expect(result).not_to be_nil
        route, path_params = result
        expect(route.path).to eq("/airports/:code")
        expect(path_params).to eq({ "code" => "JFK" })
      end

      it "returns nil for segment count mismatch" do
        result = router.resolve(Kirei::Routing::Verb::GET, "/airports")
        expect(result).to be_nil
      end

      it "returns nil for wrong verb" do
        result = router.resolve(Kirei::Routing::Verb::POST, "/airports/JFK")
        expect(result).to be_nil
      end
    end

    context "with multi-segment dynamic routes" do
      before do
        described_class.add_routes([
                                     Kirei::Routing::Route.new(
                                       verb: Kirei::Routing::Verb::GET,
                                       path: "/users/:user_id/posts/:post_id",
                                       controller: RouterSpecDummy::DummyController,
                                       action: "show",
                                     ),
                                   ])
      end

      it "extracts multiple path parameters" do
        result = router.resolve(Kirei::Routing::Verb::GET, "/users/42/posts/7")
        expect(result).not_to be_nil
        route, path_params = result
        expect(route.path).to eq("/users/:user_id/posts/:post_id")
        expect(path_params).to eq({ "user_id" => "42", "post_id" => "7" })
      end
    end

    context "when both static and dynamic routes match" do
      before do
        described_class.add_routes([
                                     Kirei::Routing::Route.new(
                                       verb: Kirei::Routing::Verb::GET,
                                       path: "/airports/special",
                                       controller: RouterSpecDummy::DummyController,
                                       action: "index",
                                     ),
                                     Kirei::Routing::Route.new(
                                       verb: Kirei::Routing::Verb::GET,
                                       path: "/airports/:code",
                                       controller: RouterSpecDummy::DummyController,
                                       action: "show",
                                     ),
                                   ])
      end

      it "matches the static route for /airports/special" do
        result = router.resolve(Kirei::Routing::Verb::GET, "/airports/special")
        expect(result).not_to be_nil
        route, path_params = result
        expect(route.action).to eq("index")
        expect(path_params).to eq({})
      end

      it "matches the dynamic route for /airports/JFK" do
        result = router.resolve(Kirei::Routing::Verb::GET, "/airports/JFK")
        expect(result).not_to be_nil
        route, path_params = result
        expect(route.action).to eq("show")
        expect(path_params).to eq({ "code" => "JFK" })
      end
    end
  end
end
