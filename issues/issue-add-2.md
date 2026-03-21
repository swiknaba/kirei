# Add `render_json` / `render_error` Helpers

## Problem

Every controller action must manually serialize data with `Oj.dump(...)` and construct the Rack response tuple. The framework provides `Kirei::Errors::JsonApiError` but there's no convenient way to render it as a response. This is repeated boilerplate in every action.

## Justification

- Reduces per-controller boilerplate significantly
- Provides a consistent response format across the entire application
- Connects the existing `JsonApiError` structs to actual HTTP responses
- Prevents common mistakes (forgetting content-type, inconsistent error formats)

## Implementation Plan

1. **Add `render_json` to `Routing::Base`** (next to existing `render`):

```ruby
sig do
  params(
    data: T.untyped,
    status: Integer,
    headers: T::Hash[String, String],
  ).returns(RackResponseType)
end
def render_json(data, status: 200, headers: {})
  body = Oj.dump(data, Kirei::OJ_OPTIONS)
  render(body, status: status, headers: headers)
end
```

2. **Add `render_error` to `Routing::Base`**:

```ruby
sig do
  params(
    errors: T::Array[Errors::JsonApiError],
    status: Integer,
    headers: T::Hash[String, String],
  ).returns(RackResponseType)
end
def render_error(errors, status: 422, headers: {})
  body = Oj.dump({ "errors" => errors.map(&:serialize) }, Kirei::OJ_OPTIONS)
  render(body, status: status, headers: headers)
end
```

3. **Update README and test app** to demonstrate the new helpers.
4. **Keep `render`** as-is for raw string responses (e.g. plain text, pre-serialized data).
