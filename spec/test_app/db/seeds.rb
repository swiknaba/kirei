# typed: strict
# frozen_string_literal: true

Airports::Models::Airport.query.delete

test = Airports::Models::Airport.new(
  id: Airports::Models::Airport.generate_human_id,
  name: "A test airport with a human ID",
  latitude: 0.0,
  longitude: 0.0
)

muc = Airports::Models::Airport.new(
  id: "MUC",
  name: "Munich Airport",
  latitude: 48.3537,
  longitude: 11.7750
)

ber = Airports::Models::Airport.new(
  id: "BER",
  name: "Berlin Brandenburg Airport",
  latitude: 52.3667,
  longitude: 13.5033
)

sfo = Airports::Models::Airport.new(
  id: "SFO",
  name: "San Francisco International Airport",
  latitude: 37.6188,
  longitude: -122.3750
)

Airports::Models::Airport.db.transaction do
  test.save
  muc.save
  ber.save
  sfo.save
end

Flights::Models::Flight.query.delete

lh100 = Flights::Models::Flight.new(
  id: "LH100-1",
  flight_number: "LH100",
  departure_airport_id: "MUC",
  arrival_airport_id: "SFO",
  departure_time: Time.new(2025, 3, 15, 10, 30, 0)
)

lh200 = Flights::Models::Flight.new(
  id: "LH200-1",
  flight_number: "LH200",
  departure_airport_id: "BER",
  arrival_airport_id: "MUC",
  departure_time: Time.new(2025, 3, 15, 14, 0, 0)
)

Flights::Models::Flight.db.transaction do
  lh100.save
  lh200.save
end
