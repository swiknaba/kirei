# Kirei

Kirei is a strictly typed Ruby micro/REST-framework for building scalable and performant APIs. It is built from the ground up to be clean and easy to use. Kirei is based on [Sequel](https://github.com/jeremyevans/sequel) as an ORM, [Sorbet](https://github.com/sorbet/sorbet) for typing, and [Rack](https://github.com/rack/rack) as web server interface. It strives to have zero magic and to be as explicit as possible.

Kirei's main advantages over other frameworks are its strict typing, low memory footprint, and build-in high-performance logging and metric-tracking toolkits. It is opiniated in terms of tooling, allowing you to focus on your core-business. It is a great choice for building APIs that need to scale.

> Kirei (きれい) is a Japanese adjective that primarily means "beautiful" or "pretty." It can also be used to describe something that is "clean" or "neat."

## Why another Ruby framework?

TL;DR:

* **zero magic**
* **strict typing**
* **very few low level dependencies**
* ultra low memory footprint
* high performance
* simple to understand

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
gem 'kirei', git: 'git@github.com:swiknaba/kirei', branch: :main
```

## Usage

### Initial Set Up

Scaffold a new project:

```shell
bundle exec kirei new "MyApp"
```

### Quick Start

Find a test app in the [spec/test_app](spec/test_app) directory. It is a fully functional example of a Kirei app.

#### Models

All models must inherit from `T::Struct` and include `Kirei::BaseModel`. They must implement `id` which must hold the primary key of the table. The primary key must be named `id` and be of type `T.any(String, Integer)`.

```ruby
class User < T::Struct
  extend T::Sig
  include Kirei::BaseModel

  const :id, T.any(String, Integer)
  const :name, String
end

user = User.find_by({ name: 'John' }) # T.nilable(User)
users = User.where({ name: 'John' })  # T::Array[User]
```

Updating a record returns a new instance. The original instance is not mutated:

```ruby
updated_user = user.update({ name: 'Johnny' })
user.name         # => 'John'
updated_user.name # => 'Johnny'
```

To build more complex queries, Sequel can be used directly:

```ruby
query = User.db.where({ name: 'John' })
query = query.where('...')
query = query.limit(10) # query is a Sequel::Dataset, chain as you like

users = User.resolve(query)            # T::Array[User]
first_user = User.resolve_first(query) # T.nilable(User)

# you can also cast the raw result manually
first_user = User.from_hash(query.first.stringify_keys)
```

#### Database Migrations

Read the [Sequel Migrations](https://github.com/jeremyevans/sequel/blob/5.78.0/doc/schema_modification.rdoc) documentation for detailed information.

```ruby
Sequel.migration do
  up do
    create_table(:airports) do
      primary_key :id
      String :name, null: false
    end
  end

  down do
    drop_table(:airports)
  end
end
```

Applying migrations:

```shell
# create the database
bundle exec rake db:create

# drop the database
bundle exec rake db:drop

# apply all pending migrations
bundle exec rake db:migrate

# roll back the last n migration
STEPS=1 bundle exec rake db:rollback

# run db/seeds.rb to seed the database
bundle exec rake db:migrate

# scaffold a new migration file
bundle exec rake 'db:migration[CreateAirports]'
```

#### Routing

Define routes anywhere in your app; by convention, they are defined in `config/routes.rb`:

```ruby
# config/routes.rb

Kirei::Router.add_routes([
  Kirei::Router::Route.new(
    verb: "GET",
    path: "/livez",
    controller: Controllers::Health,
    action: "livez",
  ),

  Kirei::Router::Route.new(
    verb: "GET",
    path: "/airports",
    controller: Controllers::Airports,
    action: "index",
  ),
])
```

#### Controllers

Controllers can be defined anywhere; by convention, they are defined in the `app/controllers` directory:

```ruby
module Controllers
  class Airports < Kirei::BaseController
    extend T::Sig

    sig { returns(Kirei::Middleware::RackResponseType) }
    def index
      airports = Airport.all # T::Array[Airport]

      # or use a serializer
      data = Oj.dump(airports.map(&:serialize))

      render(status: 200, body: data)
    end
  end
end
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
