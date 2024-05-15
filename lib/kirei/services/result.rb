# typed: strict
# frozen_string_literal: true

module Kirei
    module Services
  class Result
    extend T::Sig
    extend T::Generic

    ResultType = type_member { { fixed: T.untyped } }

    sig { returns(T.nilable(ResultType)) }
    attr_reader :result

    sig { returns(T::Array[Errors::JsonApiError]) }
    attr_reader :errors

    sig do
      params(
        result: T.nilable(ResultType),
        errors: T::Array[Errors::JsonApiError]
      ).void
    end
    def initialize(result: nil, errors: [])
      if (result && !errors.empty?) || (!result && errors.empty?)
        raise ArgumentError, "Must provide either result or errors"
      end

      @result = result
      @errors = errors
    end

    sig { returns(T::Boolean) }
    def success?
      @errors.empty?
    end

    sig { returns(T::Boolean) }
    def failed?
      !success?
    end

    sig { returns(ResultType) }
    def get_result!
      raise "Cannot call result when there are errors" if failed?
     
        @result
    end

    sig { returns(T::Array[Errors::JsonApiError]) }
    def get_errors!
      raise "Cannot call errors when there is a result" if success?
     
     @errors
    end
  end
end
end