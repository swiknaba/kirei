# typed: true
# frozen_string_literal: true

require "bundler/setup"
require "concurrent-ruby"
require "dotenv/load"
require "fileutils"
require "oj"
require "pg"
require "rake"
require "sequel"
require "sinatra"
require "sinatra/namespace"
require "sorbet-runtime"
