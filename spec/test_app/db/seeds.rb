Airport.db.delete

muc = Airport.new(
  id: 'MUC',
  name: 'Munich Airport'
)
muc.save

ber = Airport.new(
  id: 'BER',
  name: 'Berlin Brandenburg Airport'
)
ber.save

sfo = Airport.new(
  id: 'SFO',
  name: 'San Francisco International Airport'
)
sfo.save
