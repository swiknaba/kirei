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
      puts "filter running AFTER any action in any controller"
    end
  end
end
