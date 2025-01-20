# typed: strict
# frozen_string_literal: true

module Kirei
  module Routing
    RackEnvType = T.type_alias do
      #
      # in plain rack, the value could be any of:
      #
      #   T::Array[T.untyped]
      #   IO
      #   T::Boolean
      #   String
      #   Numeric
      #   TCPSocket
      #   StringIO
      #
      # The web server (e.g. Puma) might alter this to e.g.
      #   ::Puma::Client
      #   ::Puma::Configuration
      #
      # Thus we leave it as T.untyped.
      #
      T::Hash[String, T.untyped]
    end
  end
end
