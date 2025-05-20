# AGENTS.md

This document provides additional context and guidance for LLMs working with the Kirei framework. While the [README](README.md) contains basic documentation, this file focuses on aspects that might not be immediately obvious when navigating the codebase.

## Overview

Kirei is a Ruby micro-framework specifically designed for building JSON REST APIs. Its key characteristics are:
- Built with Sorbet for strict type checking
- Focused on JSON REST API development
- Minimal dependencies (Rack, Sequel, Sorbet)
- Zero magic, explicit design

## Codebase Structure

### Source Code
- Framework implementation: `lib/kirei/`
- CLI tools: `lib/cli/`
- Main entry point: `lib/kirei.rb`

### Testing
- Unit tests: `spec/` directory
  - Tests individual framework components
  - Ensures type safety and functionality
- Integration tests & documentation: `spec/test_app/`
  - Complete example application
  - Demonstrates framework usage
  - Serves as living documentation

Note: For code style fixes, use `bundle exec rubocop -A` to automatically correct Rubocop offenses. This is more efficient than manually addressing each linting error.

## Framework Structure

### Core Components and Their Responsibilities
- `lib/kirei.rb`: Framework initialization, configuration, and dependency loading
- `lib/kirei/controller.rb`: Request handling, parameter validation, and response formatting
- `lib/kirei/model.rb`: Database interaction layer, query building, and result mapping
- `lib/kirei/domain/`: Domain object implementations and value object support
- `lib/kirei/routing/`: Route definition, matching, and controller dispatching
- `lib/kirei/services/`: Service layer with logging, metrics, and execution tracking

For reference implementations, see:
- `spec/test_app/app.rb`: Example application setup
- `spec/test_app/config.ru`: Rack configuration and middleware setup

### Component Dependencies
- Controllers depend on Routing for request handling
- Models depend on Sequel for database operations
- Services can be used by Controllers and other Services
- Domain objects can use Models for persistence
- All components use Sorbet for type checking

### Framework Architecture
- Built on Rack for web server interface
- Uses Sequel for database operations
- Integrates Sorbet for type checking
- Implements immutable data structures
- Provides standardized logging and metrics collection

### Key Design Decisions
- Zero magic approach - explicit over implicit
- Immutable by default
- Strict typing throughout
- Low memory footprint focus
- Performance-first logging and metrics

## CLI and Project Scaffolding

The framework provides a CLI tool for scaffolding new projects:

### Implementation
- Located in `lib/cli/` directory
- Main entry point: `lib/cli.rb`
- Scaffolding logic: `lib/cli/commands/new_app/`

### Usage
```shell
bundle exec kirei new "MyApp"
```

This command:
1. Creates a new directory with the application name
2. Sets up the basic project structure
3. Initializes necessary configuration files
4. Sets up the database configuration
5. Creates a basic README and other documentation

The scaffolded project follows the framework's conventions and includes:
- Basic directory structure
- Configuration files
- Database setup
- Example controllers and models
- Test setup

## Framework Usage

### Project Structure
When using Kirei, follow these conventions:
- Place controllers in `app/controllers/`
- Define routes in `config/routes.rb`
- Place middleware in `config/middleware/*.rb`
- Reference implementation available in `spec/test_app/`

### Type System Usage
When building applications with Kirei:
- Models should inherit from `T::Struct` and include `Kirei::Model`
- Use type signatures (`sig`) in controllers and services
- Define model primary keys as `id` of type `T.any(String, Integer)`

### Database Usage
When working with the database:
- Models are immutable by convention (use `const` for properties)
- Updates return new instances rather than mutating existing ones
- Complex queries can be built using Sequel's DSL directly
- Use migrations for schema changes

### Domain-Driven Design
When implementing DDD:
- Use `Kirei::Model` as the persistence layer
- Implement domain concepts through `Kirei::Domain::Entity` and `Kirei::Domain::ValueObject`
- Entities should be identified by their ID
- Value Objects should be identified by their attributes

### Best Practices
When building applications:
- Keep controllers thin and delegate to services
- Use POROs (Plain Old Ruby Objects) for services
- Implement explicit and typed error handling
- Avoid direct database access in controllers
- Use `Kirei::Services::Runner` for standardized logging

## Framework Validation

There are two ways to validate the framework works:

### Unit Tests
- Located in `spec/` directory
- Run with `bundle exec rspec`
- Tests individual components and their interactions
- Ensures framework functionality in isolation
- Type checks MUST succeed: `bundle exec spoom srb tc`
  - All type signatures must be valid
  - No type errors are allowed
  - Type checking is a required part of the test suite

For convenience, all checks (Rubocop, type checking, and tests) can be run with:
```shell
bin/lint
```

### Test Application
The test app in `spec/test_app/` serves as a complete reference implementation and integration test:

#### Structure
- `spec/test_app/app.rb`: Application setup and configuration
- `spec/test_app/config.ru`: Rack configuration and middleware setup
- `spec/test_app/app/controllers/`: Example controllers
- `spec/test_app/app/models/`: Example models
- `spec/test_app/config/routes.rb`: Route definitions
- `spec/test_app/db/migrations/`: Database migrations
- `spec/test_app/spec/`: Test examples

#### Development Workflow
To validate the framework through the test app:
1. `cd spec/test_app`
2. Run database commands:
   - `bundle exec rake db:migrate` for migrations
   - `bundle exec rake db:annotate` for model annotations
   - `bundle exec rake db:seed` for seeding data
3. Start the server: `bundle exec puma`
4. Verify the application boots and functions correctly

When in doubt about implementation details or patterns, refer to the test app for concrete examples.

## Performance Considerations

- Built-in high-performance logging and metrics
- Use `Kirei::Services::Runner` for standardized logging and performance tracking
- Low memory footprint is a key design goal

## Common Patterns and Anti-patterns

- Controllers should be thin and delegate to services
- Services can be POROs (Plain Old Ruby Objects)
- Error handling should be explicit and typed
- Avoid direct database access in controllers
