# typed: strict
# frozen_string_literal: true

module Airports
  module Controllers
    class AirportsController < ::Controllers::Base
      sig { returns(T.anything) }
      def index
        search = T.let(params.fetch("q", nil), T.nilable(String))

        service = Kirei::Services::Runner.call("Airports::Services::Filter") do
          Airports::Services::Filter.call(search)
        end
        return render_error(service.errors, status: 400) if service.failed?

        airports = service.result

        Kirei::Logging::Metric.call(
          Utils::MetricTypes::AIRPORTS_SEARCH_TERM.serialize,
          tags: {
            "search.term": search,
            "results.count": airports.count,
            "results.0.id": airports.first&.id,
          }
        )

        render_json(airports.map(&:serialize))
      end

      sig { returns(T.anything) }
      def show
        render_json({ "code" => params.fetch("code") })
      end
    end
  end
end
