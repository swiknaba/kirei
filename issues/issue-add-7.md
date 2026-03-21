# Add Configuration Validation on Boot

## Problem

`Kirei.configure` silently accepts any values. If `app_name` is blank, `db_url` is malformed, or required config is missing, the error only surfaces later at runtime — often deep in a request cycle. Boot-time validation is a simple fail-fast improvement.

## Justification

- Fail-fast: catch misconfigurations during boot, not during the first request
- Better DX: clear error messages pointing to the misconfiguration
- Low effort, high impact

## Implementation Plan

1. **Add a `validate!` method to `Kirei::Config`**:

```ruby
sig { void }
def validate!
  raise "app_name must not be blank" if app_name.nil? || app_name.strip.empty?

  if db_url && !db_url.start_with?("postgresql://", "postgres://")
    raise "db_url must be a valid PostgreSQL connection string, got: #{db_url}"
  end

  if log_level.nil?
    raise "log_level must be set"
  end
end
```

2. **Call `validate!` after `Kirei.configure`** in `lib/kirei.rb`:

```ruby
Kirei.configure(&:itself)
T.must(Kirei.configuration).validate!
```

3. **Keep validations minimal**: Only validate things that will definitely fail later. Don't over-validate (e.g. don't test DB connectivity at boot — that's what `/readyz` is for).
