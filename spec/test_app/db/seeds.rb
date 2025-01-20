# typed: strict
# frozen_string_literal: true

Aviation::Models::Airport.query.delete

test = Aviation::Models::Airport.new(
  id: Aviation::Models::Airport.generate_human_id,
  name: "A test airport with a human ID",
  latitude: 0.0,
  longitude: 0.0
)

muc = Aviation::Models::Airport.new(
  id: "MUC",
  name: "Munich Airport",
  latitude: 48.3537,
  longitude: 11.7750
)

ber = Aviation::Models::Airport.new(
  id: "BER",
  name: "Berlin Brandenburg Airport",
  latitude: 52.3667,
  longitude: 13.5033
)

sfo = Aviation::Models::Airport.new(
  id: "SFO",
  name: "San Francisco International Airport",
  latitude: 37.6188,
  longitude: -122.3750
)

Aviation::Models::Airport.db.transaction do
  test.save
  muc.save
  ber.save
  sfo.save
end
