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
        status: 200,
        body: data,
      )
    end
  end
end
