# typed: strict
# frozen_string_literal: true

module Flights
  module Controllers
    class FlightsController < ::Controllers::Base
      sig { returns(T.anything) }
      def index
        departure = T.let(params.fetch("from", nil), T.nilable(String))

        service = Kirei::Services::Runner.call("Flights::Services::Search") do
          Flights::Services::Search.call(departure_airport_id: departure)
        end
        return render_error(service.errors, status: 400) if service.failed?

        render_json(service.result.map(&:serialize))
      end
    end
  end
end
