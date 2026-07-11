# typed: strict
# frozen_string_literal: true

module Controllers
  class Base < Kirei::Controller
    extend T::Sig

    # Declare a route directly on the controller that serves it, e.g.:
    #
    #   route(Kirei::Routing::Verb::GET, "/airports", :index)
    #
    # `self` is the controller class, so the route registers against it without
    # any other package having to reference the controller constant.
    sig { params(verb: Kirei::Routing::Verb, path: String, action: Symbol).void }
    def self.route(verb, path, action)
      Kirei::Routing::Router.add_routes(
        [Kirei::Routing::Route.new(verb: verb, path: path, controller: self, action: action.to_s)],
      )
    end

    before do
      # set this to e.g. the ID of the currently authenticated user
      # avoid PII, since this is attached to each log line.
      Thread.current[:enduser_id] = "user_c9998ac1"
    end

    after do
      Kirei::Logging::Logger.call(
        level: Kirei::Logging::Level::DEBUG,
        label: "after request action",
        meta: { "debug" => "me" },
      )
    end
  end
end
