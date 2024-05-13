# typed: strict
# frozen_string_literal: true

module Controllers
  class AirportsController < Base
    before do
      puts "running before filter from Airports 1"
      TestApp.config.logger.info("running ANOTHER filter from Airports 1")
    end

    before do
      puts "running before filter from Airports 2"
    end

    after do
      puts "running AFTER filter from Airports 1"
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
