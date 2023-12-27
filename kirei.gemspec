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
    "oss@dbl.works",
    "lud@reinmiedl.com",
  ]

  spec.summary = "Kirei is a strictly typed Ruby micro/REST-framework for building scaleable and performant APIs."
  spec.description = <<~TXT
    Kirei's structure und developer experience is inspired by Rails, but it's not a Rails clone.
    It's a framework that's built from the ground up to be strictly typed, performant and scaleable.
  TXT
  spec.homepage = "https://github.com/dbl-works/kirei"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["homepage_uri"] = spec.homepage

  spec.files = Dir[
    "kirei.gemspec",
    ".irbrc",
    "lib/**/*",
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
  spec.add_dependency "activesupport", "~> 6.0"
  spec.add_dependency "oj", "~> 3.0"
  spec.add_dependency "rake", "~> 13.0"
  spec.add_dependency "sorbet-runtime", "~> 0.5"
  spec.add_dependency "tzinfo-data", "~> 1.0" # for containerized environments, e.g. on AWS ECS

  # Web server & routing
  spec.add_dependency "puma", "~> 6.0"
  spec.add_dependency "sinatra", "~> 3.0"
  spec.add_dependency "sinatra-contrib", "~> 3.0"

  # Database (Postgres)
  spec.add_dependency "pg", "~> 1.0"
  spec.add_dependency "sequel", "~> 5.0"
  spec.add_dependency "sequel_pg", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
