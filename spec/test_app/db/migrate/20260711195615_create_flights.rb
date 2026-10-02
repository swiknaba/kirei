# typed: false
# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:flights) do
      String :id, null: false, primary_key: true
      String :flight_number, null: false
      String :departure_airport_id, null: false
      String :arrival_airport_id, null: false
      Time :departure_time, null: false
    end
  end

  down do
    drop_table(:flights)
  end
end
