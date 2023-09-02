# typed: false
# frozen_string_literal: true

# This is the entrypoint into the application,
# This file loads first, hence we don't have Sorbet loaded yet.

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("./../Gemfile", __dir__)

#
# Load Order is important!
#

# First: check if all gems are installed correctly
require "bundler/setup"

# Second: load all gems, development dependencies first
Bundler.require(:default)

require "active_support/all"
require "oj"
require "sorbet-runtime"
require "puma"
require "sinatra"
require "sinatra/namespace" # from sinatra-contrib
require "pg"
require "rom"
require "rom-sql"
# require "sequel_pg"

Oj.default_options = {
  mode: :compat, # required to dump hashes with symbol-keys
  symbol_keys: true,
}

# Third: load all application code
Dir[File.join(__dir__, "lib/kirei/**/*.rb")].each { require(_1) }
