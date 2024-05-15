# typed: true
# frozen_string_literal: true

module Airports
  class Filter
    extend T::Sig

    sig do
      params(
        search: T.nilable(String),
      ).returns(Kirei::Services::Result[T::Array[Airport]])
    end
    def self.call(search)
      return test_errors if test_failure? # simulate a failure for testing purposes
      return Kirei::Services::Result.new(result: Airport.all) if search.nil?

      #
      # SELECT *
      # FROM "airports"
      # WHERE (("name" ILIKE 'xx%') OR ("id" ILIKE 'xx%'))
      #
      query = Airport.db.where(Sequel.ilike(:name, "#{search}%"))
      query = query.or(Sequel.ilike(:id, "#{search}%"))

      Kirei::Services::Result.new(result: Airport.resolve(query))
    end

    sig { returns(T::Boolean) }
    def self.test_failure?
      Kernel.rand < 0.3 ? true : false
    end

    sig { returns(Kirei::Services::Result[T::Array[Airport]]) }
    def self.test_errors
      err = Kirei::Errors::JsonApiError.new(
        code: "500",
        detail: "Service failed",
      )

      Kirei::Services::Result.new(errors: [err])
    end
  end
end
