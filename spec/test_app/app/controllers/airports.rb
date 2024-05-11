# typed: strict
# frozen_string_literal: true

module Controllers
  class Airports < Base
    sig { returns(Kirei::Routing::RackResponseType) }
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
