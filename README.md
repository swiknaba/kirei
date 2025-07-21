# Kirei

Kirei is a strictly typed Ruby micro/REST-framework for building scalable and performant APIs. It is built from the ground up to be clean and easy to use. Kirei is based on [Sequel](https://github.com/jeremyevans/sequel) as an ORM, [Sorbet](https://github.com/sorbet/sorbet) for typing, and [Rack](https://github.com/rack/rack) as web server interface. It strives to have zero magic and to be as explicit as possible.

Kirei's main advantages over other frameworks are its strict typing, low memory footprint, and build-in high-performance logging and metric-tracking toolkits. It is opiniated in terms of tooling, allowing you to focus on your core-business. It is a great choice for building APIs that need to scale.

> Kirei (きれい) is a Japanese adjective that primarily means "beautiful" or "pretty." It can also be used to describe something that is "clean" or "neat."

👉 AI-generated wiki available on [DeepWiki.com](https://deepwiki.com/swiknaba/kirei).

## Why another Ruby framework?

TL;DR:

* **zero magic**
* **strict typing**
* **very few low level dependencies**
* low memory footprint
* high performance
* simple to understand

## Versioning

This gem follows SemVer, however only after a stable release 1.0.0 is made.

A changelog is maintained via the [GitHub Releases page](https://github.com/swiknaba/kirei/releases).

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

All models must inherit from `T::Struct` and include `Kirei::Model`. They must implement `id` which must hold the primary key of the table. The primary key must be named `id` and be of type `T.any(String, Integer)`.

Kirei models are immutable by convention - all properties are defined using `const` and updating a record returns a new instance rather than mutating the original. This immutability, combined with strict typing, makes them naturally suitable for both traditional data-centric applications and domain-driven design approaches.

In a domain-driven design, `Kirei::Model` serves as the persistence layer, while domain concepts are expressed through `Entity` and `ValueObject`. The domain layer might combine or transform data from multiple models to match the domain's understanding, keeping the internal data structure separate from the public interface.

```ruby
class User < T::Struct
  extend T::Sig
  include Kirei::Model

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

Delete keeps the original object intact. Returns `true` if the record was deleted. Calling delete multiple times will return `false` after the first (successful) call.

```ruby
success = user.delete # => T::Boolean

# or delete by any query:
User.query.where('...').delete # => Integer, number of deleted records
```

To build more complex queries, Sequel can be used directly:

```ruby
query = User.query.where({ name: 'John' })
query = query.where('...') # "query" is a 'Sequel::Dataset' that you can chain as you like
query = query.limit(10)

users = User.resolve(query)            # T::Array[User]
first_user = User.resolve_first(query) # T.nilable(User)

# you can also cast the raw result manually
first_user = User.from_hash(query.first.stringify_keys)
```

#### Domain Objects

Kirei provides support for Domain-Driven Design patterns through `Kirei::Domain::Entity` and `Kirei::Domain::ValueObject`. Here's how to use them:

```ruby
# An Entity is identified by its ID
class Flight < T::Struct
  include Kirei::Domain::Entity

  const :id, Integer

  const :flight_number, String
  const :departure_airport_id, Integer
  const :arrival_airport_id, Integer
  const :scheduled_departure_at, Time
  const :status, String

  sig { returns(T::Boolean) }
  def can_board?
    Time.now.utc <= scheduled_departure_at && status == 'on_time'
  end
end

# A Value Object is identified by its attributes
# I.e. two Coordinates with the same lat/long will be equal
# regardless of object identity
class Coordinates < T::Struct
  include Kirei::Domain::ValueObject

  const :latitude, Float
  const :longitude, Float

  sig { returns(String) }
  def to_s
    "#{latitude},#{longitude}"
  end

  sig { params(other_coords: Coordinates).returns(Float) }
  def distance_to(other_coords)
    # Implement e.g. Haversine here.
  end
end

# Usage example
coords = Coordinates.new(latitude: 37.6188, longitude: -122.3750)
coords2 = Coordinates.new(latitude: 37.6188, longitude: -122.3750)

coords == coords2 # true

flight = Flight.new(id: 123, flight_number: 'UA123', status: 'on_time', scheduled_departure_at: Time.now.utc)
flight2 = Flight.new(id: 123, flight_number: 'UA123', status: 'delayed', scheduled_departure_at: Time.now.utc)

flight == flight2 # true - same entity even with different status
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

# annotate the models with the schema
# this runs automatically after each migration
bundle exec rake db:annotate

# roll back the last n migration
STEPS=1 bundle exec rake db:rollback

# run db/seeds.rb to seed the database
bundle exec rake db:seed

# scaffold a new migration file
bundle exec rake 'db:migration[CreateAirports]'
```

#### Routing

Define routes anywhere in your app; by convention, they are defined in `config/routes.rb`:

```ruby
# config/routes.rb

module Kirei::Routing
  Router.add_routes(
    [
      Route.new(
        verb: Verb::GET,
        path: "/livez",
        controller: Controllers::Health,
        action: "livez",
      ),
      Route.new(
        verb: Verb::GET,
        path: "/airports",
        controller: Controllers::Airports,
        action: "index",
      ),
    ],
  )
end
```

#### Controllers

Controllers can be defined anywhere; by convention, they are defined in the `app/controllers` directory:

```ruby
module Controllers
  class Airports < Kirei::Controller
    extend T::Sig

    sig { returns(T.anything) }
    def index
      search = T.let(params.fetch("q", nil), T.nilable(String))

      airports = Kirei::Services::Runner.call("Airports::Filter") do
        Airports::Filter.call(search) # T::Array[Airport]
      end

      # or use a serializer
      data = Oj.dump(airports.map(&:serialize))

      render(status: 200, body: data)
    end
  end
end
```

Services can be PORO. You can wrap an execution in `Kirei::Services::Runner` which will emit a standardized logline and track its execution time.

```ruby
module Airports
  class Filter
    extend T::Sig

    sig do
      params(
        search: T.nilable(String),
      ).returns(T::Array[Airport])
    end
    def self.call(search)
      return Airport.all if search.nil?

      #
      # SELECT *
      # FROM "airports"
      # WHERE (("name" ILIKE 'xx%') OR ("id" ILIKE 'xx%'))
      #
      query = Airport.query.where(Sequel.ilike(:name, "#{search}%"))
      query = query.or(Sequel.ilike(:id, "#{search}%"))

      Airport.resolve(query)
    end
  end
end
```

### Goes well with these gems

* [pagy](https://github.com/ddnexus/pagy) for pagination
* [argon2](https://github.com/technion/ruby-argon2) for password hashing
* [rack-session](https://github.com/rack/rack-session) for session management

### Middlewares

If you place custom middlewares under `config/middleware/*.rb`, they will be automatically loaded, see [app.rb](spec/test_app/app.rb) "load configs".

However, you still need to `use` them in the `config.ru` file, see the generated [config.ru](spec/test_app/config.ru) file, this gives you full control over the order in which middlewares are executed:

```ruby
# Load middlewares here
use(Rack::Reloader, 0) if TestApp.environment == "development"

# add more custom middlewares here, e.g.
use(Middleware::Example)

# Launch the app
run(TestApp.new)
```

Middleware provided by a gem like [rack-session](https://github.com/rack/rack-session) must be added to the `config.ru` file as well if you want to use it.

## Contributions

We welcome contributions from the community. Before starting work on a major feature, please get in touch with us either via email or by opening an issue on GitHub. "Major feature" means anything that changes user-facing features or significant changes to the codebase itself.

Please commit small and focused PRs with descriptive commit messages. If you are unsure about a PR, please open a draft PR to get early feedback. A PR must have a short description ("what"), a motiviation ("why"), and, if applicable, instructions how to test the changes, measure performance improvements, etc.

## Publishing a new version

run

```shell
bin/release
```

which will guide you through the release process.
