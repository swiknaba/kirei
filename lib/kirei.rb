# typed: strict
# frozen_string_literal: true

require "boot"

module Kirei
  extend T::Sig

  # we don't know what Oj does under the hood with the options hash, so don't freeze it
  # rubocop:disable Style/MutableConstant
  OJ_OPTIONS = T.let(
    {
      mode: :compat, # required to dump hashes with symbol-keys
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

Kirei.configure(&:itself)

Kirei::Logger.logger.info("Kirei (#{Kirei::VERSION}) booted successfully!")
