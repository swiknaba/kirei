# typed: false
# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:airports) do
      String :id, null: false, primary_key: true
      String :name, null: false
      Float :latitude, null: false
      Float :longitude, null: false
    end
  end

  down do
    drop_table(:airports)
  end
end
