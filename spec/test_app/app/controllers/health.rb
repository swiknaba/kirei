# typed: strict
# frozen_string_literal: true

module Controllers
  class Health < Kirei::BaseController
    extend T::Sig

    sig { returns(Kirei::Middleware::RackResponseType) }
    def livez
      puts(params.inspect)
      render(status: 200, body: "OK")
    end
  end
end
