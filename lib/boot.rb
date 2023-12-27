# typed: false
# frozen_string_literal: true

# This is the entrypoint into the application,
# This file loads first, hence we don't have Sorbet loaded yet.

#
# Load Order is important!
#

# First: check if all gems are installed correctly
require "bundler/setup"

# Second: load all gems (runtime dependencies only)
require "sorbet-runtime"
require "oj"
require "active_support/all"
require "puma"
require "sinatra"
require "sinatra/namespace" # from sinatra-contrib
require "pg"
require "sequel"
require "rom"
require "rom-sql"

Oj.default_options = {
  mode: :compat, # required to dump hashes with symbol-keys
  symbol_keys: false, # T::Struct.new works only with string-keys
}

# Third: load all application code
Dir[File.join(__dir__, "kirei/**/*.rb")].each { require(_1) }
