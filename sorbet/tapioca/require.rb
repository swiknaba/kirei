# typed: strict
# frozen_string_literal: true

require "bundler/setup"
require "concurrent-ruby"
require "dotenv/load"
require "fileutils"
require "oj"
require "pg"
require "sequel"
require "sorbet-runtime"
require "puma"
require "zeitwerk"
