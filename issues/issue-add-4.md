# Add Typed Parameter Validation

## Problem

Params arrive as raw `Hash[String, T.untyped]`. There's no built-in way to validate presence, coerce types (string → integer), or whitelist allowed params. Every controller action repeats manual `params.fetch(...)` with ad-hoc validation. The framework shouldn't become a full validation library, but a lightweight typed params declaration covers the 80% case.

## Justification

- Reduces per-action boilerplate (fetch, type-check, coerce, error-return)
- Plays naturally with Sorbet's `T::Struct` — the building block already used everywhere
- Failed coercion can automatically return 400 with JSON:API errors
- Keeps the framework explicit (no magic, user declares what they expect)

## Implementation Plan

1. **Struct-based approach**: Let users declare params as a `T::Struct`:

```ruby
class CreateUserParams < T::Struct
  const :name, String
  const :email, String
  const :age, T.nilable(Integer)
end
```

2. **Add a `typed_params` helper to `Controller`**:

```ruby
sig do
  type_parameters(:P)
    .params(klass: T.class_of(T::Struct))
    .returns(T.type_parameter(:P))
end
def typed_params(klass)
  klass.from_hash(params)
rescue ArgumentError, TypeError => e
  raise Kirei::ParamValidationError, e.message
end
```

3. **Catch `ParamValidationError` in the exception handler** (see issue-add-3) and return a 400 JSON:API error response.

4. **Basic coercion helpers** (optional): A small module that coerces string values to declared types before passing to `from_hash`. This handles the common case of query params arriving as strings.

### Scope Boundaries

- **In scope**: Presence validation, basic type coercion (string → int/float/bool), Sorbet struct-based declaration.
- **Out of scope**: Complex validations (format, range, custom rules). Users should use a gem like `dry-validation` for that, or write plain Ruby.
