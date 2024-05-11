# typed: strict
# frozen_string_literal: true

module Controllers
  class Airports < Kirei::BaseController
    extend T::Sig

    sig { returns(Kirei::Middleware::RackResponseType) }
    def index
      airports = Airport.all
      data = Oj.dump(airports.map(&:serialize))

      render(
        data,
        status: 200,
      )
    end
  end
end
