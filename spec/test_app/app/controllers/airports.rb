# typed: strict
# frozen_string_literal: true

require_relative("base") # TODO: use Zeitwerk

module Controllers
  class Airports < Base
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
