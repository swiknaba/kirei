# typed: strict
# frozen_string_literal: true

module Kirei
  module Services
    class Result
      extend T::Sig
      extend T::Generic

      ErrorType = type_member { { fixed: T::Array[Errors::JsonApiError] } }
      ResultType = type_member { { upper: Object } }

      sig do
        params(
          result: T.nilable(ResultType),
          errors: ErrorType,
        ).void
      end
      def initialize(result: nil, errors: [])
        if (result && !errors.empty?) || (!result && errors.empty?)
          raise ArgumentError, "Must provide either result or errors, got both or neither"
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
      def result
        raise "Cannot call 'result' when there are errors" if failed?

        T.must(@result)
      end

      sig { returns(ErrorType) }
      def errors
        raise "Cannot call 'errors' when there is a result" if success?

        @errors
      end
    end
  end
end
