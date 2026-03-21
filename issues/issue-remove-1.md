# Remove `Services::ArrayComparison`

## Problem

`Services::ArrayComparison` is a utility class that compares two arrays with three modes (strict, ignore order, ignore order + duplicates). It's 36 lines dedicated to a concern that is:

- Not a framework-level responsibility
- Only used internally by `ValueObject#equal_with_array_mode?` (which is itself niche — see issue-remove-2)
- Trivially implementable with 3 one-liners in a `case` statement

## Justification

- Reduces framework API surface and perceived bloat
- Not related to web framework concerns (routing, models, logging)
- Users needing array comparison can write their own trivially
- Follows the "80% well, 20% yourself" principle — this is firmly in the 20%

## Implementation Plan

1. **Remove** `lib/kirei/services/array_comparison.rb`
2. **If keeping `equal_with_array_mode?`** (see issue-remove-2): inline the 3-line comparison logic directly in `ValueObject`. Otherwise, remove both.
3. **Remove tests** covering `ArrayComparison` in isolation.
4. **No migration/deprecation needed** — this class has no known external consumers.

### Files to Modify

- `lib/kirei/services/array_comparison.rb` — delete
- `lib/kirei/domain/value_object.rb` — remove reference or inline logic
- Related specs
