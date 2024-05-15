# typed: strict
# frozen_string_literal: true

module Controllers
  class AirportsController < Base
    sig { returns(T.anything) }
    def index
      search = T.let(params.fetch("q", nil), T.nilable(String))

      result = Kirei::Services::Runner.call("Airports::Filter") do
        Airports::Filter.call(search)
      end

      if result.failed?
        errs = { "errors" => result.errors.map(&:serialize)}
        return render(Oj.dump(errs), status: 400)
      end

      airports = result.result

      Kirei::Logging::Metric.call(
        MetricTypes::AIRPORTS_SEARCH_TERM.serialize,
        tags: {
          "search.term": search,
          "results.count": airports.count,
          "results.0.id": airports.first&.id,
        }
      )

      data = Oj.dump(airports.map(&:serialize))

      render(
        data,
        status: 200,
      )
    end
  end
end
