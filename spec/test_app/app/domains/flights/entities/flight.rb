# typed: strict
# frozen_string_literal: true

module Flights
  module Entities
    class Flight < T::Struct
      include Kirei::Domain::Entity

      const :id, String
      const :flight_number, String
      const :departure_airport, Airports::Entities::Airport # cross-domain public API reference
      const :arrival_airport, Airports::Entities::Airport   # cross-domain public API reference
      const :departure_time, Time
    end
  end
end
