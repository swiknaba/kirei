# typed: true

# Minimal shim for `statsd-instrument`.
# The gem is an optional dependency — this shim lets Sorbet
# type-check `StatsdBackend` without requiring the gem at analysis time.
module StatsD
  extend T::Sig

  sig { params(name: String, value: T.any(Integer, Float), tags: T.untyped).void }
  def self.increment(name, value = 1, tags: {}); end

  sig { params(name: String, value: T.any(Integer, Float), tags: T.untyped).void }
  def self.measure(name, value, tags: {}); end

  sig { params(name: String, value: T.any(Integer, Float), tags: T.untyped).void }
  def self.gauge(name, value, tags: {}); end
end
