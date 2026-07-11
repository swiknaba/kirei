# typed: strict
# frozen_string_literal: true

module Flights
  module Services
    class Search < T::Struct
      extend T::Sig

      sig do
        params(departure_airport_id: T.nilable(String))
          .returns(Kirei::Services::Result[T::Array[Flights::Entities::Flight]])
      end
      def self.call(departure_airport_id: nil)
        # 1. Query flights from own persistence layer (internal)
        flights_query = Flights::Models::Flight.query
        flights_query = flights_query.where(departure_airport_id: departure_airport_id) if departure_airport_id
        flights = Flights::Models::Flight.resolve(flights_query)

        # 2. Look up airports from the Airports domain's PUBLIC API (cross-domain)
        airport_ids = flights.flat_map { |f| [f.departure_airport_id, f.arrival_airport_id] }.uniq
        airports_by_id = Airports::Services::Filter.call_by_ids(airport_ids)

        # 3. Build domain entities
        result = flights.map do |flight|
          Flights::Entities::Flight.new(
            id: flight.id,
            flight_number: flight.flight_number,
            departure_airport: airports_by_id.fetch(flight.departure_airport_id),
            arrival_airport: airports_by_id.fetch(flight.arrival_airport_id),
            departure_time: flight.departure_time,
          )
        end

        Kirei::Services::Result.new(result: result)
      end
    end
  end
end
