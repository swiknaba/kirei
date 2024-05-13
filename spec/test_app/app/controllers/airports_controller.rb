# typed: strict
# frozen_string_literal: true

module Controllers
  class AirportsController < Base
    before do
      TestApp.config.logger.info(
        "filter running BEFORE any action of AirportsController",
      )
    end

    after do
      puts "running AFTER filter from Airports"
    end

    sig { returns(T.anything) }
    def index
      search = params.fetch("q", nil)
      airports = ::Airports::Filter.call(search)

      data = Oj.dump(airports.map(&:serialize))

      render(
        data,
        status: 200,
      )
    end
  end
end
