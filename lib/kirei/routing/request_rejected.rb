# typed: strict
# frozen_string_literal: true

module Kirei
  module Routing
    # Raised while reading a request body when the request itself is at fault.
    # `Base#call` renders it as a JSON:API error with the given status.
    class RequestRejected < StandardError
      extend T::Sig

      sig { returns(Integer) }
      attr_reader :status

      sig { returns(String) }
      attr_reader :code

      sig { params(status: Integer, code: String, detail: String).void }
      def initialize(status:, code:, detail:)
        @status = status
        @code = code
        super(detail)
      end
    end
  end
end
