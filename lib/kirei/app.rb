# typed: strict
# frozen_string_literal: true

require_relative("middleware")

module Kirei
  class App
    include Middleware
    extend T::Sig

    sig { void }
    def initialize
      @router = T.let(Router.new, Router)
    end

    sig { params(_env: RackEnvType).returns(RackResponseType) }
    def call(_env)
      [
        200,
        {},
        ["Hello from Kirei"],
      ]
    end
  end
end
