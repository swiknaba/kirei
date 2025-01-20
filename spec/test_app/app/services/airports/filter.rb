# typed: strict
# frozen_string_literal: true

module Airports
  class Filter < T::Struct
    extend T::Sig

    sig do
      params(
        search: T.nilable(String)
      ).returns(Kirei::Services::Result[T::Array[Aviation::Entities::Airport]])
    end
    def self.call(search)
      return test_errors if test_failure? # simulate a failure for testing purposes

      # Internal: Fetch airports from persistence layer
      airports = if search.nil?
        Aviation::Models::Airport.all
      else
        query = Aviation::Models::Airport.query
          .where(Sequel.ilike(:name, "#{search}%"))
          .or(Sequel.ilike(:id, "#{search}%"))

        Aviation::Models::Airport.resolve(query)
      end

      # Domain Boundary: Map internal models to public domain objects
      result = airports.map do |airport|
        coordinates = Aviation::ValueObjects::Coordinates.new(
          latitude: airport.latitude,
          longitude: airport.longitude
        )

        Aviation::Entities::Airport.new(
          id: airport.id,
          name: airport.name,
          coordinates: coordinates
        )
      end

      Kirei::Services::Result.new(result: result)
    end

    sig { returns(T::Boolean) }
    def self.test_failure?
      Kernel.rand < 0.3 ? true : false
    end

    sig { returns(Kirei::Services::Result[T::Array[Aviation::Entities::Airport]]) }
    def self.test_errors
      err = Kirei::Errors::JsonApiError.new(
        code: "500",
        detail: "Service failed",
      )

      Kirei::Services::Result.new(errors: [err])
    end
  end
end
