# Make `statsd-instrument` Optional

## Problem

`statsd-instrument` is a **hard runtime dependency** in the gemspec. Not every small backend or microservice uses StatsD/Datadog for metrics. Teams using Prometheus, OpenTelemetry, or no metrics at all are forced to install and configure a StatsD backend they don't use.

The framework calls `StatsD.increment` and `StatsD.measure` directly in:
- `Routing::Base#call` (request timing)
- `Services::Runner#call` (service timing)
- `Logging::Metric.call` (custom metrics)

## Justification

- Reduces mandatory dependencies for users who don't need StatsD
- Many microservices/small backends use Prometheus or no metrics at all
- The gem adds ~2MB to the bundle
- Metrics should be a pluggable concern, not a hard requirement

## Implementation Plan

1. **Make `statsd-instrument` an optional dependency**: Move from `add_dependency` to documentation ("add to your Gemfile if you want StatsD metrics").

2. **Add a no-op fallback**: When `statsd-instrument` is not installed, metric calls should silently no-op:

```ruby
module Kirei
  module Logging
    class Metric
      def self.call(metric_name, value = 1, tags: {})
        return unless defined?(::StatsD)
        # existing logic
      end
    end
  end
end
```

3. **Guard the `StatsD.measure` calls** in `Routing::Base` and `Services::Runner` with `defined?(::StatsD)`.

4. **Alternatively, make metrics pluggable** via config:

```ruby
prop :metrics_backend, T.nilable(T.class_of(Kirei::Logging::MetricsBackend)), default: nil
```

where `MetricsBackend` is an interface with `increment` and `measure` methods. Ship a `StatsdBackend` and a `NullBackend`.

### Decision Point

Option A (simpler): `defined?(::StatsD)` guards. Quick to implement, no new abstractions.

Option B (cleaner): Pluggable metrics backend. More work upfront, but allows Prometheus/OTel adapters in the future.

### Files to Modify

- `kirei.gemspec` — remove `statsd-instrument` from `add_dependency`
- `lib/kirei.rb` — conditionally require `statsd-instrument`
- `lib/kirei/logging/metric.rb` — add guard / no-op
- `lib/kirei/routing/base.rb` — guard `StatsD.measure` call
- `lib/kirei/services/runner.rb` — guard `StatsD.measure` call
