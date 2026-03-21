# Remove `ValueObject#equal_with_array_mode?`

## Problem

`ValueObject#equal_with_array_mode?` is a niche method that allows comparing value objects with custom array comparison semantics. It's the only consumer of `Services::ArrayComparison` (see issue-remove-1), and it solves a problem that virtually no user will encounter.

If someone needs custom equality semantics for arrays inside value objects, they can simply override `==` on their specific value object class.

## Justification

- Very niche use case — custom array equality in value objects
- Pulls in `ArrayComparison` as a dependency for a method nobody is likely to call
- Users who need this can trivially override `==` themselves
- Removing this simplifies `ValueObject` to its essential purpose: attribute-based equality

## Implementation Plan

1. **Remove `equal_with_array_mode?`** from `lib/kirei/domain/value_object.rb`
2. **Remove the `ArrayComparison` reference** from `ValueObject` (ties into issue-remove-1)
3. **Update tests** — remove any specs for `equal_with_array_mode?`
4. **Document in README** that users can override `==` if they need custom equality

### Files to Modify

- `lib/kirei/domain/value_object.rb` — remove `equal_with_array_mode?` method
- Related specs
