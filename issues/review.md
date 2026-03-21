# Kirei Framework Review

A thorough analysis of the framework's current state, with recommendations for additions and removals aligned with the goal: **small footprint, superior performance, 80% of boilerplate covered**.

---

## Current Scope Summary

| Layer | Components | Lines (approx) |
|---|---|---|
| **Routing** | Rack middleware, param parsing, hooks, CORS, security headers | ~350 |
| **Controller** | Base class, before/after hooks, request object | ~100 |
| **Model** | Sequel ORM wrapper, CRUD, human-ID generator, pgvector, JSONB | ~460 |
| **Logging** | Threaded structured JSON logger, sensitive value masking | ~275 |
| **Metrics** | StatsD wrapper with default tags | ~40 |
| **Services** | Runner (timing + logging), Result monad, ArrayComparison | ~160 |
| **Domain** | Entity (identity equality), ValueObject (attribute equality) | ~65 |
| **Errors** | JSON:API error structs | ~40 |
| **Helpers** | [underscore](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/helpers.rb#11-19), [blank?](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/helpers.rb#22-25), `deep_stringify/symbolize_keys` | ~90 |
| **CLI** | Project scaffolding (`kirei new`) | ~10 files |
| **Rake** | `kirei:routes` task | ~25 |

**Runtime dependencies (10):** `rack`, `sorbet-runtime`, `sequel`, `sequel_pg`, `pg`, `oj`, `statsd-instrument`, `zeitwerk`, [logger](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/logging/logger.rb#58-71), `tzinfo-data`

---

## 🟢 Features to Add

### 1. Path Parameters (High Priority)

The router currently does **exact string matching only** — no support for `/users/:id` or `/airports/:code`. This is arguably the single biggest gap for any REST API framework. Every real-world API needs parameterized routes.

> **Suggestion:** Support named segments (`:param`) in route paths. Merge matched segments into `params`. Keep it simple — no regex routes, no optional segments, no glob routes.

### 2. Middleware Stack (High Priority)

Currently the framework relies entirely on Rack middleware declared in [config.ru](file:///Users/lr/Sites/swiknaba/kirei/spec/test_app/config.ru). There's no programmatic middleware API within Kirei itself. This makes it hard to:
- Conditionally apply middleware per-route or per-controller
- Share state set by middleware (e.g. authenticated user) in a typed way

> **Suggestion:** A lightweight `Kirei::Middleware` base class or module with a [call(env, next_middleware)](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/services/runner.rb#18-42) interface. Could be controller-scoped (via hooks) or app-scoped. Keep it thin — Rack middleware for global concerns, Kirei middleware for controller-scoped logic.

### 3. Request/Response Body Serialization Helpers (Medium Priority)

Controllers currently must manually call `Oj.dump(...)` and construct the Rack response tuple. This is boilerplate every action repeats.

> **Suggestion:** Add a `render_json(data, status: 200)` helper that handles serialization + content-type. Also consider a `render_error(errors, status:)` that formats JSON:API error responses, since `Kirei::Errors::JsonApiError` already exists but there's no convenient way to render it.

### 4. Parameter Validation / Coercion (Medium Priority)

Params arrive as raw `Hash[String, untyped]`. There's no built-in way to validate, coerce (string → integer), or whitelist params. While the framework shouldn't become a full validation library, a lightweight typed params declaration would cover the 80% case.

> **Suggestion:** A small DSL or struct-based approach: declare expected params as a `T::Struct`, coerce from the raw hash. Failed coercion → automatic 400 with JSON:API errors. This plays well with Sorbet.

### 5. Exception Handling / Rescue Layer (Medium Priority)

There is **no global exception handler**. If a controller action raises, it bubbles up through Rack. The `ensure` block in [base.rb](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/routing/base.rb) handles metrics/logging but doesn't rescue the exception itself. Every production API needs a "catch-all → 500 JSON response" layer.

> **Suggestion:** Add a `rescue` block in `Routing::Base#call` that catches `StandardError`, logs it, and returns a structured JSON error response. Allow users to register custom exception handlers (e.g. `ActiveRecord::RecordNotFound → 404`).

### 6. Health Check Endpoints (Low Priority — Scaffold only)

The test app has a health controller, but the framework doesn't scaffold or provide built-in `/livez` and `/readyz` endpoints. These are expected by Kubernetes and most deployment targets.

> **Suggestion:** Provide `/livez` (always 200) and `/readyz` (pings the DB) as opt-in built-in routes, or at minimum include them in `kirei new` scaffolding.

### 7. Configuration Validation on Boot (Low Priority)

`Kirei.configure` silently accepts anything. If `app_name` is blank or [db_url](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/app.rb#64-70) is malformed, the error surfaces later at runtime.

> **Suggestion:** Add a `Config#validate!` call at boot to eagerly catch misconfigurations.

---

## 🔴 Components to Strip or Rethink

### 1. `Services::ArrayComparison` — **Remove**

This is a utility class that compares two arrays with three modes (strict, ignore order, ignore order + duplicates). It's:
- Only 36 lines, but it's not framework-level concern
- Used only by `ValueObject#equal_with_array_mode?`
- Trivially implementable inline (3 one-liners in a `case`)

> **Impact:** Removing this and inlining the logic in `ValueObject` saves a class, reduces API surface, and avoids the perception of bloat. [equal_with_array_mode?](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/domain/value_object.rb#28-39) itself is also questionable — consider removing it from the framework and letting users implement their own equality semantics.

### 2. `Domain::ValueObject#equal_with_array_mode?` — **Remove**

This is a very niche method. If someone needs custom array comparison in value object equality, they can override [==](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/domain/entity.rb#14-20). This pulls in [ArrayComparison](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/services/array_comparison.rb#6-34) as a dependency for a use case that almost nobody will hit.

### 3. `Helpers#blank?` — **Remove**

The implementation is `string.nil? || string.to_s.empty?` — it takes a `T.any(String, Symbol)` but calls `.nil?` on it (which can never be true given the type signature). More importantly, this is trivial Ruby and doesn't belong in a framework. It encourages ActiveSupport-style thinking.

### 4. `Helpers` Deep Key Transformation — **Evaluate**

[deep_stringify_keys](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/helpers.rb#27-30), [deep_symbolize_keys](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/helpers.rb#37-40), and their bang variants are 60+ lines of code. They're used internally in the logger and model layer. The non-bang variants could be removed since the bang variants are what's actually used internally. Assess if the public API variants are needed.

> **Suggestion:** Keep [deep_stringify_keys!](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/helpers.rb#32-35) and [deep_symbolize_keys!](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/helpers.rb#42-45) as internal/private; drop the non-bang public versions to reduce surface area.

### 5. `statsd-instrument` Dependency — **Make Optional**

This is a hard runtime dependency. Not every small backend or microservice uses StatsD/Datadog. For teams using Prometheus, OpenTelemetry, or nothing at all, this is forced overhead.

> **Suggestion:** Make metrics a pluggable concern. Ship a no-op default. The `Logging::Metric.call` and `StatsD.measure` calls in `Routing::Base` and `Services::Runner` should check if a metrics backend is configured and no-op otherwise. The gem dependency should move to an optional/recommended position.

### 6. `tzinfo-data` Dependency — **Make Optional**

This is a ~5MB gem that bundles timezone data for systems that don't have it (Alpine Linux, Windows). Most users deploying on standard Linux or macOS don't need it. It's unnecessary weight.

> **Suggestion:** Remove from runtime dependencies. Document it as "add to your Gemfile if deploying on Alpine Linux."

### 7. [Verb](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/routing/verb.rb#6-36) Enum — **Trim**

`TRACE` and `CONNECT` HTTP verbs are included but handled as no-ops with `[200, {}, []]`. No REST API microservice will ever define a TRACE or CONNECT route. They add dead branches in the `case` statement.

> **Suggestion:** Remove `TRACE` and `CONNECT` from the enum. If someone needs them, they can use Rack middleware.

### 8. `pgvector` Support in Model — **Extract**

The [vector_column?](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/model/class_methods.rb#108-115) and [cast_to_vector](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/model/class_methods.rb#117-126) methods in `Model::ClassMethods` are ~25 lines supporting a very niche use case (vector embeddings). This adds a schema-inspection call on every insert for non-vector users.

> **Suggestion:** Extract pgvector support into an optional mixin or a separate gem (`kirei-pgvector`). The [wrap_jsonb_non_primivitives!](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/model/class_methods.rb#88-101) method currently interleaves vector logic with JSONB logic — they should be separated.

---

## ⚡ Performance Observations

### Good
- Threaded logging queue avoids blocking request handling
- `Process.clock_gettime` with `:float_millisecond` is the fastest timing mechanism
- Immutable models by convention avoids hidden state mutation
- Singleton router with hash lookup is O(1) for exact matches

### Potential Issues
- **Schema inspection per insert**: [vector_column?](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/model/class_methods.rb#108-115) calls `db.schema(table_name)` which hits the database. This should be cached.
- **`Model#save` does a SELECT before INSERT/UPDATE**: The [find_by](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/model/class_methods.rb#132-135) call on every [save](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/model.rb#36-49) is an extra DB roundtrip. Consider `INSERT ... ON CONFLICT` (upsert) for Postgres.
- **No connection pooling configuration**: Sequel handles this, but the framework doesn't expose pool size tuning.

---

## ✅ What to Keep As-Is

| Component | Rationale |
|---|---|
| **Routing core** | Simple, fast, explicit. Just needs path params. |
| **Structured logging** | Excellent — threaded, JSON, sensitive value masking, OTel conventions. Core differentiator. |
| **Model layer** | Clean Sequel wrapper, immutable-by-convention. Right level of abstraction. |
| **Domain objects** | `Entity` and `ValueObject` are tiny, useful, and well-designed (after stripping [equal_with_array_mode?](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/domain/value_object.rb#28-39)). |
| **JSON:API errors** | Good format choice, needs a render helper. |
| **Services::Runner** | Useful pattern, well-integrated with logging and metrics. |
| **Services::Result** | Clean Result monad. |
| **Config** | Clean `T::Struct` config with sane defaults. |
| **Security headers** | Good defaults, user-overridable. |
| **CLI scaffolding** | Essential for DX. |
| **HumanIdGenerator** | Useful, well-implemented. |

---

## Summary Matrix

| Action | Item | Impact |
|---|---|---|
| 🟢 **Add** | Path parameters | Unblocks real-world routing |
| 🟢 **Add** | `render_json` / `render_error` helpers | Reduces per-controller boilerplate |
| 🟢 **Add** | Global exception handler | Production safety |
| 🟢 **Add** | Typed param validation (struct-based) | Reduces per-action boilerplate |
| 🟢 **Add** | Lightweight middleware API | Route/controller-scoped middleware |
| 🟢 **Add** | Health check scaffolding | K8s readiness |
| 🟢 **Add** | Config validation on boot | Fail-fast DX |
| 🔴 **Remove** | [ArrayComparison](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/services/array_comparison.rb#6-34) | Bloat; inline if needed |
| 🔴 **Remove** | `ValueObject#equal_with_array_mode?` | Niche; users can override [==](file:///Users/lr/Sites/swiknaba/kirei/lib/kirei/domain/entity.rb#14-20) |
| 🔴 **Remove** | `Helpers#blank?` | Trivial Ruby |
| 🔴 **Trim** | `Helpers` non-bang deep_*_keys | Reduce public API surface |
| 🔴 **Extract** | `pgvector` support | Separate gem/mixin |
| 🔴 **Make optional** | `statsd-instrument` | Not universally used |
| 🔴 **Make optional** | `tzinfo-data` | Unnecessary for most deployments |
| 🔴 **Trim** | `TRACE`/`CONNECT` verbs | Dead code paths |
