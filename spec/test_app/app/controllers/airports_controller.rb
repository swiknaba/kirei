# typed: strict
# frozen_string_literal: true

module Controllers
  class AirportsController < Base
    sig { returns(T.anything) }
    def all
      search = T.let(params.fetch("q", nil), T.nilable(String))

      future = Kirei::Services::Runner.async do
        Airports::Filter.call(search)
      end

      # we can start more async jobs here, or do other blocking stuff
      # while the airports are being fetched

      # here we block/wait for the future to complete
      service = T.let(
        Kirei::Services::Runner.await(future),
        Kirei::Services::Result[T::Array[Airport]],
      )

      if service.failed?
        errs = { "errors" => service.errors.map(&:serialize)}
        return render(Oj.dump(errs), status: 400)
      end

      airports = service.result

      render(
        Oj.dump(airports.map(&:serialize)),
        status: 200,
      )
    end


    sig { returns(T.anything) }
    def index
      search = T.let(params.fetch("q", nil), T.nilable(String))

      service = Kirei::Services::Runner.call("Airports::Filter") do
        Airports::Filter.call(search)
      end

      if service.failed?
        errs = { "errors" => service.errors.map(&:serialize)}
        return render(Oj.dump(errs), status: 400)
      end

      airports = service.result

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
