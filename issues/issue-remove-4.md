# Trim `Helpers` Non-Bang Deep Key Transforms

## Problem

`Helpers` exposes four deep key transformation methods:

- `deep_stringify_keys` (non-mutating) — ~15 lines
- `deep_stringify_keys!` (mutating) — ~15 lines
- `deep_symbolize_keys` (non-mutating) — ~15 lines
- `deep_symbolize_keys!` (mutating) — ~15 lines

Plus two private `deep_transform_keys` / `deep_transform_keys!` backing methods (~30 lines).

Internally, the framework only uses the **bang variants**:
- `deep_stringify_keys!` is used in `Logging::Logger`
- `deep_symbolize_keys!` is used in `Model#save`
- `deep_stringify_keys` (non-bang) is used in `Model::ClassMethods#create`

The non-bang `deep_symbolize_keys` is unused.

## Justification

- Reducing public API surface means less to maintain and document
- The non-bang variants allocate new hashes unnecessarily when the bang variant works
- `deep_symbolize_keys` (non-bang) has zero usages
- Keep only what's actually needed

## Implementation Plan

1. **Audit usages** of all four methods across framework and test app
2. **Remove `deep_symbolize_keys`** (non-bang) — zero framework usages
3. **Evaluate `deep_stringify_keys`** (non-bang) — used in `Model::ClassMethods#create`. Consider switching to the bang variant, or keep if immutability is important there
4. **Mark remaining methods as internal** if they don't need to be public API
5. **Update tests** accordingly

### Files to Modify

- `lib/kirei/helpers.rb` — remove unused methods
- Related specs
