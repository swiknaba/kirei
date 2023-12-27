# Kirei

Kirei is a strictly typed Ruby micro/REST-framework for building scalable and performant APIs. It is built from the ground up to be clean and easy to use. Kirei is based on [Sequel](https://github.com/jeremyevans/sequel) as an ORM, [Sorbet](https://github.com/sorbet/sorbet) for typing, and [Sinatra](https://github.com/sinatra/sinatra) for routing. It strives to have zero magic and to be as explicit as possible.

Kirei's main advantages over other frameworks are its strict typing, low memory footprint, and build-in high-performance logging and metric-tracking toolkits. It is opiniated in terms of tooling, allowing you to focus on your core-business. It is a great choice for building APIs that need to scale.

> Kirei (きれい) is a Japanese adjective that primarily means "beautiful" or "pretty." It can also be used to describe something that is "clean" or "neat."

## Why another Ruby framework?

TL;DR:

* **zero magic**
* **strict typing**
* ultra low memory footprint
* high performance
* simple to understand
* very few low level dependencies

## Versioning

This gem follows SemVer, however only after a stable release 1.0.0 is made.

A changelog is maintained in the [CHANGELOG.md](CHANGELOG.md) file and/or the GitHub Releases page.

## Installation

Via rubygems:

```ruby
gem 'kirei'
```

Test the latest version via git:

```ruby
gem 'kirei', git: 'git@github.com:dbl-works/kirei', branch: :main
```

## Usage

### Initial Set Up

Scaffold a new project:

```shell
bundle exec kirei new "MyApp"
```

## Contributions

We welcome contributions from the community. Before starting work on a major feature, please get in touch with us either via email or by opening an issue on GitHub. "Major feature" means anything that changes user-facing features or significant changes to the codebase itself.

Please commit small and focused PRs with descriptive commit messages. If you are unsure about a PR, please open a draft PR to get early feedback. A PR must have a short description ("what"), a motiviation ("why"), and, if applicable, instructions how to test the changes, measure performance improvements, etc.

## Publishing a new version

run

```shell
bin/release
```

which will guide you through the release process.
