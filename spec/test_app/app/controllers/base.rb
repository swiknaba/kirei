# typed: strict
# frozen_string_literal: true

module Controllers
  class Base < Kirei::Controller
    extend T::Sig

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
