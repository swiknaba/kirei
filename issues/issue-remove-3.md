# Remove `Helpers#blank?`

## Problem

`Helpers.blank?` is defined as:

```ruby
sig { params(string: T.any(String, Symbol)).returns(T::Boolean) }
def blank?(string)
  string.nil? || string.to_s.empty?
end
```

Issues:
- The type signature says `T.any(String, Symbol)` — neither can be `nil`, so `string.nil?` is dead code
- This is trivial Ruby (`str.empty?`) and doesn't belong in a framework
- Encourages ActiveSupport-style thinking, which conflicts with the "zero magic" philosophy

## Justification

- Dead code in the nil check (Sorbet would flag this)
- Trivial enough that any developer can write `str.to_s.empty?` inline
- Reduces framework API surface
- Aligns with "explicit over magical" philosophy

## Implementation Plan

1. **Find all internal usages** of `Helpers.blank?`:
   - `lib/kirei/logging/logger.rb` line 159: `Kirei::Helpers.blank?(prefix)`
2. **Replace with inline check**: `prefix.empty?` (since `prefix` is always a `String`)
3. **Remove** the `blank?` method from `lib/kirei/helpers.rb`
4. **Update tests** — remove any specs for `blank?`

### Files to Modify

- `lib/kirei/helpers.rb` — remove `blank?` method
- `lib/kirei/logging/logger.rb` — replace usage with `prefix.empty?`
- Related specs
