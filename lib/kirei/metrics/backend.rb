# typed: strict
# frozen_string_literal: true

module Kirei
  module Metrics
    class Backend
      extend T::Sig
      extend T::Helpers

      abstract!

      sig do
        abstract.params(
          name: String,
          value: T.any(Integer, Float),
          tags: T::Hash[String, T.untyped],
        ).void
      end
      def increment(name, value = 1, tags: {})
      end

      sig do
        abstract.params(
          name: String,
          duration_ms: T.any(Integer, Float),
          tags: T::Hash[String, T.untyped],
        ).void
      end
      def measure(name, duration_ms, tags: {})
      end

      sig do
        abstract.params(
          name: String,
          value: T.any(Integer, Float),
          tags: T::Hash[String, T.untyped],
        ).void
      end
      def gauge(name, value, tags: {})
      end
    end
  end
end
