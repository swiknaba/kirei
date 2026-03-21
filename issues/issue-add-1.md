# Add Path Parameters

## Problem

The router currently performs **exact string matching only** — there is no support for parameterized routes like `/users/:id` or `/airports/:code`. Every real-world REST API needs this.

Currently, a user would need to define a separate route for each resource instance, which is impractical. This is the single biggest feature gap for a REST framework.

## Justification

- Unblocks real-world routing (e.g. `GET /users/:id`, `PUT /orders/:id/items/:item_id`)
- Without this, Kirei cannot serve as a standalone API framework
- Every comparable framework (Sinatra, Roda, Grape) supports this

## Implementation Plan

1. **Modify `Routing::Route`**: Add a `dynamic?` flag or detect `:param` segments in the path at registration time.
2. **Modify `Routing::Router#get`**: For non-exact matches, fall back to pattern matching against registered dynamic routes. Pre-compile segment patterns at registration time to avoid regex on every request.
3. **Extract named params**: When a dynamic route matches, extract the named segments (e.g. `{ "id" => "42" }`) and merge them into `params`.
4. **Keep it simple**: Only support `:named` segments. No regex routes, no optional segments, no glob/splat routes. This covers 95% of use cases.
5. **Update `Routing::Base#call`**: Merge path params into the existing `params` hash before dispatching to the controller.

### Example API

```ruby
Route.new(
  verb: Verb::GET,
  path: "/users/:id",
  controller: Controllers::Users,
  action: "show",
)

# In the controller:
def show
  user_id = params.fetch("id") # extracted from the path
end
```

### Performance Consideration

- Static routes should still use O(1) hash lookup (no regression)
- Dynamic routes can use a separate ordered list with pre-compiled segment arrays
- Matching cost: split path by `/` and compare segment-by-segment — very fast
