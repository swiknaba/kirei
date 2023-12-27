# typed: strict
# frozen_string_literal: true

module Kirei
  #
  # Add `extend Kirei::BaseModel` to your models.
  #
  module BaseModel
    extend T::Sig
    include T::Sig

    # the attached class is the class that extends this module
    # e.g. "User"
    extend T::Generic
    has_attached_class!

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
      ).returns(T::Array[T.attached_class])
    end
    def resolve(query, strict = nil)
      query.map do |row|
        row = T.cast(row, T::Hash[Symbol, T.untyped])
        row.stringify_keys! # sequel returns symbolized keys
        from_hash(row, strict)
      end
    end
  end
end
