lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kirei/version"

Gem::Specification.new do |spec|
  spec.name = "kirei"
  spec.version = Kirei::VERSION
  spec.authors = [
    "Ludwig Reinmiedl",
  ]
  spec.email = [
    "lud@reinmiedl.com",
    "oss@dbl.works",
  ]

  spec.summary = "Kirei is a typed Ruby micro/REST-framework for building scalable and performant microservices."
  spec.description = <<~TXT
    Kirei is a Ruby micro/REST-framework for building scalable and performant microservices.
    It is built from the ground up to be clean and easy to use.
    It is a Rack app, and uses Sorbet for typing, Sequel as an ORM, and Zeitwerk for autoloading.
    It strives to have zero magic and to be as explicit as possible.
  TXT
  spec.homepage = "https://github.com/swiknaba/kirei"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["homepage_uri"] = spec.homepage

  spec.files = Dir[
    "kirei.gemspec",
    ".irbrc",
    "lib/**/*",
    # do not include RBIs for gems, because users might use different verions
    "sorbet/rbi/dsl/**/*.rbi",
    "sorbet/rbi/shims/**/*.rbi",
    "LICENSE",
    "README.md",
    "CHANGELOG.md",
  ]

  spec.bindir = "bin"
  spec.executables = [File.basename("bin/kirei")]
  spec.require_paths = ["lib"]

  # Utilities
  spec.add_dependency "oj", "~> 3.0"
  spec.add_dependency "sorbet-runtime", "~> 0.5"
  spec.add_dependency "statsd-instrument", "~> 3.0"
  spec.add_dependency "tzinfo-data", "~> 1.0" # for containerized environments, e.g. on AWS ECS
  spec.add_dependency "zeitwerk", "~> 2.5"

  # Web server & routing
  spec.add_dependency "rack", "~> 3.0"

  # Database (Postgres)
  spec.add_dependency "pg", "~> 1.0"
  spec.add_dependency "sequel", "~> 5.0"
  spec.add_dependency "sequel_pg", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
