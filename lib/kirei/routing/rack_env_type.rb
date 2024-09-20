# typed: strict
# frozen_string_literal: true

module Kirei
  module Routing
    RackEnvType = T.type_alias do
      T::Hash[
        String,
        T.any(
          T::Array[T.untyped],
          IO,
          T::Boolean,
          String,
          Numeric,
          TCPSocket,
          ::Puma::Client,
          StringIO,
          ::Puma::Configuration,
        )
      ]
    end
  end
end
