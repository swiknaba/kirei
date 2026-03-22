# typed: strict
# frozen_string_literal: true

module Kirei
  module Metrics
    class StatsdBackend < Backend
      extend T::Sig

      sig { void }
      def initialize
        super
        return if defined?(::StatsD)

        raise "statsd-instrument is not loaded. Add `gem 'statsd-instrument'` to your Gemfile to use StatsdBackend."
      end

      sig do
        override.params(
          name: String,
          value: T.any(Integer, Float),
          tags: T::Hash[String, T.untyped],
        ).void
      end
      def increment(name, value = 1, tags: {})
        ::StatsD.increment(name, value, tags: tags)
      end

      sig do
        override.params(
          name: String,
          duration_ms: T.any(Integer, Float),
          tags: T::Hash[String, T.untyped],
        ).void
      end
      def measure(name, duration_ms, tags: {})
        ::StatsD.measure(name, duration_ms, tags: tags)
      end

      sig do
        override.params(
          name: String,
          value: T.any(Integer, Float),
          tags: T::Hash[String, T.untyped],
        ).void
      end
      def gauge(name, value, tags: {})
        ::StatsD.gauge(name, value, tags: tags)
      end
    end
  end
end
