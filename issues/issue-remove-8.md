# Trim `TRACE` and `CONNECT` HTTP Verbs

## Problem

The `Routing::Verb` enum includes `TRACE` and `CONNECT` verbs, and they're handled in `Routing::Base#call` with a no-op response `[200, {}, []]`. No REST API microservice will ever define a TRACE or CONNECT route:

- **TRACE** is an HTTP debugging method that echoes the request back. It's typically disabled for security reasons (cross-site tracing attacks).
- **CONNECT** establishes a tunnel for HTTPS proxying. It's a proxy concern, not an application concern.

These add dead branches in two `case` statements in `Routing::Base#call`.

## Justification

- Dead code: no user will register a TRACE or CONNECT route
- `TRACE` is a security risk (XST attacks) — returning 200 is actively wrong
- `CONNECT` is a proxy protocol, not relevant to application-level routing
- Removing simplifies the `case` statements and the `Verb` enum
- Fewer branches = marginally better branch prediction performance

## Implementation Plan

1. **Remove `TRACE` and `CONNECT` from `Routing::Verb` enum** in `lib/kirei/routing/verb.rb`
2. **Remove their branches** from both `case` statements in `Routing::Base#call`:
   - Line 64: `when Verb::HEAD, Verb::DELETE, Verb::OPTIONS, Verb::TRACE, Verb::CONNECT` → `when Verb::HEAD, Verb::DELETE, Verb::OPTIONS`
   - Line 97: `when Verb::HEAD, Verb::OPTIONS, Verb::TRACE, Verb::CONNECT` → `when Verb::HEAD, Verb::OPTIONS`
3. **Update tests** — remove any specs for TRACE/CONNECT handling
4. **If a TRACE/CONNECT request arrives**, it will now get a 404 from the router (correct behavior)

### Files to Modify

- `lib/kirei/routing/verb.rb` — remove `TRACE` and `CONNECT` enum values
- `lib/kirei/routing/base.rb` — remove from `case` branches
- Related specs
