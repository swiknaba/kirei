# typed: strict
# frozen_string_literal: true

puts "Booting Kirei..." # rubocop:disable all

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

    # convenience method since ".configuration" must be nilable since it is nil
    # at the beginning of initilization
    sig { returns(Kirei::Config) }
    def config
      T.must(configuration)
    end

    sig { returns(Pathname) }
    def root
      Pathname.new(::APP_ROOT)
    end

    sig { returns(String) }
    def version
      @version = T.let(@version, T.nilable(String))
      @version ||= ENV.fetch("APP_VERSION", nil)
      @version ||= ENV.fetch("GIT_SHA", nil)
      @version ||= `git rev-parse --short HEAD`.to_s.chomp.freeze # localhost
    end

    sig { returns(String) }
    def env
      ENV.fetch("RACK_ENV", "development")
    end

    sig { returns(String) }
    def default_db_name
      @default_db_name ||= T.let("#{config.app_name}_#{env}".freeze, T.nilable(String))
    end

    sig { returns(String) }
    def default_db_url
      @default_db_url ||= T.let(
        ENV.fetch("DATABASE_URL", "postgresql://localhost:5432/#{default_db_name}"),
        T.nilable(String),
      )
    end

    sig { returns(Sequel::Database) }
    def raw_db_connection
      @raw_db_connection ||= T.let(
        Sequel.connect(default_db_url), # calling "Sequel.connect" creates a new connection
        T.nilable(Sequel::Database),
      )
    end
  end
end

Kirei.configure(&:itself)

require "codegen"

puts "Kirei (#{Kirei::VERSION}) booted!" # rubocop:disable all
