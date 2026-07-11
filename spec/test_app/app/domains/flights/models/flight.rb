# typed: strict
# frozen_string_literal: true

# == Schema Info
#
# Table name: flights
#
#  id                  :text                not null, primary key
#  flight_number       :text                not null
#  departure_airport_id:text                not null
#  arrival_airport_id  :text                not null
#  departure_time      :timestamp without time zone, not null
#

module Flights
  module Models
    class Flight < T::Struct
      extend T::Sig
      include Kirei::Model

      const :id, String
      const :flight_number, String
      const :departure_airport_id, String # IATA code, e.g. "MUC"
      const :arrival_airport_id, String   # IATA code, e.g. "SFO"
      const :departure_time, Time
    end
  end
end
