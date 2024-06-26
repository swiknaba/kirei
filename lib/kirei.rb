# typed: strict
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
require "statsd-instrument"
require "sorbet-runtime"
require "oj"
require "rack"
require "pg"
require "sequel" # "sequel_pg" is auto-required by "sequel"

# Third: load all application code
require("zeitwerk")
loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.ignore("#{__dir__}/cli")
loader.ignore("#{__dir__}/cli.rb")
loader.setup

module Kirei
  extend T::Sig

  # we don't know what Oj does under the hood with the options hash, so don't freeze it
  # rubocop:disable Style/MutableConstant
  OJ_OPTIONS = T.let(
    {
      mode: :compat, # required to dump hashes with symbol-keys. @TODO(lud, 14.05.2024): drop this, and enforce String Keys?
      symbol_keys: false, # T::Struct.new works only with string-keys
    },
    T::Hash[Symbol, T.untyped],
  )
  # rubocop:enable Style/MutableConstant

  GEM_ROOT = T.let(
    Gem::Specification.find_by_name("kirei").gem_dir,
    String,
  )

  class << self
    extend T::Sig

    sig { returns(T.nilable(Kirei::Config)) }
    attr_accessor :configuration

    sig do
      params(
        _: T.proc.params(configuration: Kirei::Config).void,
      ).void
    end
    def configure(&_)
      self.configuration ||= Kirei::Config.new
      yield(T.must(configuration))
    end
  end
end

loader.eager_load

Kirei.configure(&:itself)

yjit_enabled = defined?(RubyVM::YJIT) ? RubyVM::YJIT.enabled? : false

Kirei::Logging::Logger.logger.info("Kirei v#{Kirei::VERSION} booted; YJIT enabled: #{yjit_enabled}")
