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
require "logger"
require "sorbet-runtime"
require "oj"
require "sinatra"
require "sinatra/namespace" # from sinatra-contrib
require "pg"
require "sequel" # "sequel_pg" is auto-required by "sequel"

# Third: load all application code
Dir[File.join(__dir__, "kirei/**/*.rb")].each { require(_1) }
