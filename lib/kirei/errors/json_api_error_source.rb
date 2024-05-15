# typed: strict
# frozen_string_literal: true

module Kirei
  module Errors
    class JsonApiErrorSource < T::Struct
      const :attribute, T.any(Symbol, String)
      const :model, T.nilable(String)
      const :id, T.nilable(String)
    end
  end
end
