# Add Lightweight Middleware API

## Problem

Currently the framework relies entirely on Rack middleware declared in `config.ru`. There's no programmatic middleware API within Kirei itself. This makes it difficult to:

- Conditionally apply middleware per-route or per-controller
- Share state set by middleware (e.g. authenticated user) in a typed way
- Compose controller-scoped concerns (auth, rate-limiting, feature flags)

The existing `before`/`after` hooks on `Controller` are limited — they're unparameterized procs with no access to the request or response.

## Justification

- Authentication middleware is needed by virtually every API
- Controller-scoped middleware is more flexible than global Rack middleware
- Hooks are too limited (no params, no request/response access, can't short-circuit)

## Implementation Plan

1. **Define a `Kirei::Middleware` interface**:

```ruby
module Kirei
  module Middleware
    extend T::Sig
    extend T::Helpers
    interface!

    sig { abstract.params(request: Routing::Request, params: T::Hash[String, T.untyped]).returns(T.nilable(Routing::RackResponseType)) }
    def call(request, params); end
  end
end
```

Returning `nil` means "proceed to the next middleware / action". Returning a `RackResponseType` short-circuits (e.g. 401 Unauthorized).

2. **Add `middleware` class method to `Controller`**:

```ruby
class UsersController < Kirei::Controller
  middleware AuthMiddleware
  middleware RateLimitMiddleware

  def index
    # ...
  end
end
```

3. **Run middleware chain in `Routing::Base#call`** after `before_hooks` but before dispatching to the action. If any middleware returns a response, return it immediately.

4. **Keep Rack middleware for global concerns** (logging, CORS, etc.). Kirei middleware is for controller-scoped logic.

### Scope Boundaries

- **In scope**: Per-controller middleware with short-circuit capability, access to request and params.
- **Out of scope**: Per-action middleware, middleware ordering configuration. Keep it simple.
