# typed: strict
# frozen_string_literal: true

require "bundler/setup"
require "concurrent-ruby"
require "dotenv/load"
require "fileutils"
require "oj"
require "pg"
require "logger"
require "sequel"
require "sequel/extensions/migration"
require "sorbet-runtime"
require "zeitwerk"
