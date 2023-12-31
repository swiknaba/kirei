# typed: strict
# frozen_string_literal: true

require "boot"

module Kirei
  extend T::Sig

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
