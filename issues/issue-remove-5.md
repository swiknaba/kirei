# Optimize `pgvector` Support in Model — Keep, Don't Remove

## Context

`Model::ClassMethods` contains ~20 lines of pgvector-specific logic:

- `vector_column?(column_name)` — calls `db.schema(table_name)` to check if a column is a vector type
- `cast_to_vector(value)` — casts an array to a Sequel vector literal
- A branch in `wrap_jsonb_non_primivitives!` that routes vector columns to `cast_to_vector`

## Original Concern (Debunked)

The original proposal claimed `vector_column?` causes "a DB roundtrip per insert" because `db.schema(...)` hits the database each time. **This is incorrect.**

Sequel caches schema information by default (`Database#cache_schema = true`). Calling `db.schema(:table_name)` only queries the database on the first invocation per table; subsequent calls return the cached result. There is no per-insert DB overhead from schema inspection.

> **Action:** Add a comment in `vector_column?` noting that Sequel caches `db.schema` results internally, so this is not a per-call DB hit.

## Decision: Keep in Core, Optimize

With the rise of AI and vector search, pgvector is no longer a niche use case. The code is ~20 lines and the heavy `pgvector` gem is not a dependency of this library — users install it themselves. Extracting this into a separate gem is overkill; extracting into a loadable mixin is unnecessary given the optimization below.

## Implementation Plan

### 1. Add early return in `wrap_jsonb_non_primivitives!` for the vector branch

Follow the existing pattern on line 91 (`return unless App.config.db_extensions.include?(:pg_json)`). Inside the `each_pair` block, skip the `vector_column?` call entirely unless pgvector is configured:

```ruby
def wrap_jsonb_non_primivitives!(attributes)
  return unless App.config.db_extensions.include?(:pg_json)

  pgvector_enabled = App.config.db_extensions.include?(:pgvector)

  attributes.each_pair do |key, value|
    if pgvector_enabled && vector_column?(key.to_s)
      attributes[key] = cast_to_vector(value)
    elsif value.is_a?(Hash) || value.is_a?(Array)
      attributes[key] = T.unsafe(Sequel).pg_jsonb_wrap(value)
    end
  end
end
```

This makes the vector support effectively **opt-in at zero cost**: users who don't add `:pgvector` to `db_extensions` never call `vector_column?` or `db.schema` at all.

### 2. Add comment about Sequel's schema caching

In `vector_column?`, document that `db.schema` is cached by Sequel so future readers don't re-raise this concern:

```ruby
# Sequel caches db.schema results internally (Database#cache_schema is true by default),
# so this only hits the database once per table per app lifecycle.
```

### 3. Update existing comments

The existing comments (lines 102–106) already document the opt-in process well. No changes needed there.

### Files to Modify

- `lib/kirei/model/class_methods.rb` — add `pgvector_enabled` guard + caching comment
- Related specs (if any test `wrap_jsonb_non_primivitives!` with vector columns)
