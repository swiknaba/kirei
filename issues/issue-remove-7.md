# Make `tzinfo-data` Optional

## Problem

`tzinfo-data` is a **hard runtime dependency** (~5MB) that bundles timezone data for systems that lack system-level timezone info (Alpine Linux, Windows). Most users deploying on standard Linux distros (Debian, Ubuntu) or macOS already have this data via the OS and don't need the gem.

## Justification

- ~5MB of added gem weight for a framework that targets "low memory footprint"
- Unnecessary for users on standard Linux/macOS
- Only needed for specific deployment environments (Alpine, Windows)
- Follows the pattern of keeping the framework lean and letting users add what they need

## Implementation Plan

1. **Remove** `tzinfo-data` from `spec.add_dependency` in `kirei.gemspec`
2. **Add a note to README** under a "Deployment" or "Containerized Environments" section:

```markdown
### Alpine Linux / Windows

If deploying on Alpine Linux or Windows, add `tzinfo-data` to your Gemfile:

​```ruby
gem 'tzinfo-data'
​```
```

3. **Add to `kirei new` scaffolding**: Include the gem in the generated `Gemfile` as a commented-out line with explanation:

```ruby
# Uncomment if deploying on Alpine Linux or Windows:
# gem 'tzinfo-data', '~> 1.0'
```

### Files to Modify

- `kirei.gemspec` — remove `tzinfo-data` dependency
- `README.md` — add deployment note
- CLI scaffolding templates — add commented gem line
