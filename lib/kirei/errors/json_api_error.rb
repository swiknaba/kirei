# typed: strict
# frozen_string_literal: true

module Kirei
  module Errors
    #
    # https://jsonapi.org/format/#errors
    # Error objects MUST be returned as an array keyed by errors in the top level of a JSON:API document.
    #
    class JsonApiError < T::Struct
      #
      # An application-specific error code, expressed as a string value.
      #
      const :code, Symbol

      #
      # A human-readable explanation specific to this occurrence of the problem.
      # Like title, this field's value can be localized.
      #
      const :detail, T.nilable(String)

      const :source, T.nilable(JsonApiErrorSource)
    end
  end
end
