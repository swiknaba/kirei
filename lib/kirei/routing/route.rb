# typed: strict
# frozen_string_literal: true

module Kirei
  module Routing
    class Route < T::Struct
      extend T::Sig

      const :verb, Verb
      const :path, String
      const :controller, T.class_of(Controller)
      const :action, String

      sig { returns(T::Array[String]) }
      def segments
        @segments ||= T.let(path.split("/"), T.nilable(T::Array[String]))
      end

      sig { returns(T::Boolean) }
      def dynamic?
        segments.any? { |s| s.start_with?(":") }
      end
    end
  end
end
