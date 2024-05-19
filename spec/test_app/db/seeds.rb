# typed: strict
# frozen_string_literal: true

Airport.db.delete

test = Airport.new(
  id: Airport.generate_human_id,
  name: "A test airport with a human ID",
)
test.save

muc = Airport.new(
  id: "MUC",
  name: "Munich Airport"
)
muc.save

ber = Airport.new(
  id: "BER",
  name: "Berlin Brandenburg Airport"
)
ber.save

sfo = Airport.new(
  id: "SFO",
  name: "San Francisco International Airport"
)
sfo.save
