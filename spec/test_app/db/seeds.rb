# typed: strict
# frozen_string_literal: true

Airport.query.delete

test = Airport.new(
  id: Airport.generate_human_id,
  name: "A test airport with a human ID",
)

muc = Airport.new(
  id: "MUC",
  name: "Munich Airport"
)

ber = Airport.new(
  id: "BER",
  name: "Berlin Brandenburg Airport"
)

sfo = Airport.new(
  id: "SFO",
  name: "San Francisco International Airport"
)

Airport.db.transaction do
  test.save
  muc.save
  ber.save
  sfo.save
end
