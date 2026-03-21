# Add Health Check Scaffolding

## Problem

The test app has a health controller, but the framework doesn't scaffold or provide built-in `/livez` and `/readyz` endpoints. These are expected by Kubernetes, AWS ECS, and most modern deployment targets. Every new Kirei app must manually create these.

## Justification

- Standard for containerized deployments (K8s liveness/readiness probes)
- Trivial to implement but easy to forget or get wrong
- `readyz` should ping the database — the framework already has DB connection logic

## Implementation Plan

1. **Add a built-in `Kirei::Controllers::Health` controller** in the framework itself:

```ruby
module Kirei
  module Controllers
    class Health < Kirei::Controller
      extend T::Sig

      sig { returns(Routing::RackResponseType) }
      def livez
        render('{"status":"ok"}', status: 200)
      end

      sig { returns(Routing::RackResponseType) }
      def readyz
        App.raw_db_connection.execute("SELECT 1")
        render('{"status":"ok"}', status: 200)
      rescue Sequel::Error => e
        render('{"status":"unavailable"}', status: 503)
      end
    end
  end
end
```

2. **Opt-in route registration**: Don't auto-register routes. Instead, provide a helper:

```ruby
# In config/routes.rb
Kirei::Routing::Router.add_health_routes! # registers /livez and /readyz
```

Or include them in `kirei new` scaffolding by default.

3. **Update CLI scaffolding** (`kirei new`) to include the health routes in the generated `config/routes.rb`.
