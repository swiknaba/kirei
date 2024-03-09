# typed: false
# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:airports) do
      primary_key :id
      String :name, null: false
    end
  end

  down do
    drop_table(:airports)
  end
end
