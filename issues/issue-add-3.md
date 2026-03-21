# Add Global Exception Handler

## Problem

There is **no global exception handler** in the framework. If a controller action raises, the exception bubbles up through Rack unhandled. The `ensure` block in `Routing::Base#call` handles metrics and logging but never rescues the exception itself. Every production API needs a "catch-all → structured 500 JSON response" layer.

## Justification

- Production safety: unhandled exceptions should never leak raw stack traces to clients
- Consistency: all error responses should follow the same JSON:API format
- Observability: exceptions should be logged in the structured format before returning
- This is table-stakes for any API framework

## Implementation Plan

1. **Add a `rescue StandardError => e` block in `Routing::Base#call`**, between the action dispatch and the `ensure` block:

```ruby
rescue StandardError => e
  status = 500

  Kirei::Logging::Logger.call(
    level: Kirei::Logging::Level::ERROR,
    label: "Unhandled Exception",
    meta: {
      "error.class" => e.class.name,
      "error.message" => e.message,
      "error.backtrace" => e.backtrace&.first(10)&.join("\n"),
    },
  )

  error = Errors::JsonApiError.new(code: "internal_server_error", detail: "An unexpected error occurred")
  body = Oj.dump({ "errors" => [error.serialize] }, Kirei::OJ_OPTIONS)

  [status, default_headers, [body]]
```

2. **Add a configurable exception handler** in `Kirei::Config`:

```ruby
prop :exception_handlers,
  T::Hash[T.class_of(StandardError), T.proc.params(e: StandardError).returns(RackResponseType)],
  default: {}
```

This lets users register custom handlers (e.g. map a `RecordNotFound` to a 404).

3. **Check custom handlers before the default 500** in the rescue block.

4. **In development mode**, optionally include the backtrace in the response body for easier debugging.
