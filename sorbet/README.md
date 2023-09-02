# Sorbet

[Sorbet](https://sorbet.org/) is a type checker for Ruby that we are gradually adopting in order to improve type-safety of our backend codebases.

We use [Tapioca](https://github.com/Shopify/tapioca) to generate and update type definitions for our gems and rails DSL.

We also use [Spoom](https://github.com/Shopify/spoom) as tooling to interact with sorbet, e.g. to bump the type strictness on all files.

## Useful commands

- `tapioca gem`: generate types for a newly added gem
- `tapioca dsl`: infer runtime types (e.g. for rails associations)
- `tapioca todo`: ignore unresolved constants (e.g. constants generated dynamically on runtime)
- `spoom tc`: run sorbet type check
- `spoom bump`: bump the strictness on all files to the maximum based on newly added type signatures

## Shims

Sorbet does not cannot detect methods that are dynamically declared. You can still declare them using a shim under `sorbet/shims/`.
