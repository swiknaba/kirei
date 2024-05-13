# typed: true
# frozen_string_literal: true

module Airports
  class Filter
    extend T::Sig

    sig do
      params(
        search: T.nilable(String),
      ).returns(T::Array[Airport])
    end
    def self.call(search)
      return Airport.all if search.nil?

      #
      # SELECT *
      # FROM "airports"
      # WHERE (("name" ILIKE 'xx%') OR ("id" ILIKE 'xx%'))
      #
      query = Airport.db.where(Sequel.ilike(:name, "#{search}%"))
      query = query.or(Sequel.ilike(:id, "#{search}%"))

      Airport.resolve(query)
    end
  end
end
