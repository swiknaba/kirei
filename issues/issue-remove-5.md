# Extract `pgvector` Support from Model

## Problem

`Model::ClassMethods` contains ~25 lines of pgvector-specific logic:

- `vector_column?(column_name)` — calls `db.schema(table_name)` (a DB hit) to check if a column is a vector type
- `cast_to_vector(value)` — casts an array to a Sequel vector literal

This code is interleaved with `wrap_jsonb_non_primivitives!`, which runs on **every insert**. The `vector_column?` check calls `db.schema(...)` each time, which is a schema-inspection query hitting the database.

For the vast majority of Kirei users who don't use pgvector, this is unnecessary overhead and conceptual complexity.

## Justification

- Very niche use case (vector embeddings / AI search)
- Adds a DB roundtrip per insert for schema inspection (not cached)
- Mixes concerns: JSONB wrapping and vector casting are orthogonal
- Follows the principle of keeping the core small; advanced features should be opt-in

## Implementation Plan

1. **Extract to an optional mixin** `Kirei::Model::PgvectorSupport`:

```ruby
module Kirei
  module Model
    module PgvectorSupport
      # vector_column? and cast_to_vector methods
      # Override wrap_jsonb_non_primivitives! to add vector handling
    end
  end
end
```

2. **Or extract to a separate gem** (`kirei-pgvector`) if the scope warrants it.

3. **Remove vector logic from `wrap_jsonb_non_primivitives!`** in the core `ClassMethods`.

4. **Cache `vector_column?` results** — the schema doesn't change at runtime, so cache after the first call per column.

5. **Update README** to document the opt-in mixin.

### Files to Modify

- `lib/kirei/model/class_methods.rb` — remove `vector_column?`, `cast_to_vector`, and vector branch in `wrap_jsonb_non_primivitives!`
- New file: `lib/kirei/model/pgvector_support.rb` (or separate gem)
- Related specs
