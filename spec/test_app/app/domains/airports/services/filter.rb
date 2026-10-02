# typed: strict
# frozen_string_literal: true

module Airports
  module Services
    class Filter < T::Struct
      extend T::Sig

      sig do
        params(
          search: T.nilable(String)
        ).returns(Kirei::Services::Result[T::Array[Airports::Entities::Airport]])
      end
      def self.call(search)
        return test_errors if test_failure? # simulate a failure for testing purposes

        # Internal: Fetch airports from persistence layer
        airports = if search.nil?
          Airports::Models::Airport.all
        else
          query = Airports::Models::Airport.query
            .where(Sequel.ilike(:name, "#{search}%"))
            .or(Sequel.ilike(:id, "#{search}%"))

          Airports::Models::Airport.resolve(query)
        end

        # Domain Boundary: Map internal models to public domain objects
        result = airports.map { |airport| to_entity(airport) }

        Kirei::Services::Result.new(result: result)
      end

      # Public API for cross-domain lookup by IATA codes.
      # Returns a hash keyed by airport id so callers can enrich their own records.
      sig { params(ids: T::Array[String]).returns(T::Hash[String, Airports::Entities::Airport]) }
      def self.call_by_ids(ids)
        airports = Airports::Models::Airport.resolve(
          Airports::Models::Airport.query.where(id: ids)
        )

        airports.to_h { |airport| [airport.id, to_entity(airport)] }
      end

      sig { params(airport: Airports::Models::Airport).returns(Airports::Entities::Airport) }
      def self.to_entity(airport)
        Airports::Entities::Airport.new(
          id: airport.id,
          name: airport.name,
          coordinates: Airports::ValueObjects::Coordinates.new(
            latitude: airport.latitude,
            longitude: airport.longitude,
          ),
        )
      end

      sig { returns(T::Boolean) }
      def self.test_failure?
        Kernel.rand < 0.3 ? true : false
      end

      sig { returns(Kirei::Services::Result[T::Array[Airports::Entities::Airport]]) }
      def self.test_errors
        err = Kirei::Errors::JsonApiError.new(
          code: "500",
          detail: "Service failed",
        )

        Kirei::Services::Result.new(errors: [err])
      end
    end
  end
end
