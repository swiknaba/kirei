# typed: strict
# frozen_string_literal: true

module Kirei
  #
  # Add `extend Kirei::BaseModel` to your models.
  #
  module BaseModel
    extend T::Sig

    sig { returns(String) }
    def table_name
      T.must(name.split("::").last).pluralize.underscore
    end

    sig { returns(Sequel::Dataset) }
    def db
      Kirei.raw_db_connection[table_name.to_sym]
    end

    sig do
      params(
        query: Sequel::Dataset,
        strict: T.untyped,
      ).returns(T::Array[BaseModel])
    end
    def resolve(query, strict = nil)
      query.all.map do |row|
        from_hash(row.to_hash, strict)
      end
    end
  end
end
