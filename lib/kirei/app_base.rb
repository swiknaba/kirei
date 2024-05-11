# typed: strict
# frozen_string_literal: true

require_relative("app")

module Kirei
  class AppBase < Kirei::App
    class << self
      extend T::Sig

      #
      # convenience method since "Kirei.configuration" must be nilable since it is nil
      # at the beginning of initilization of the app
      #
      sig { returns(Kirei::Config) }
      def config
        T.must(Kirei.configuration)
      end

      sig { returns(Pathname) }
      def root
        defined?(::APP_ROOT) ? Pathname.new(::APP_ROOT) : Pathname.new(Dir.pwd)
      end

      #
      # Returns the version of the app. It checks in the following order:
      # * ENV["APP_VERSION"]
      # * ENV["GIT_SHA"]
      # * `git rev-parse --short HEAD`
      #
      sig { returns(String) }
      def version
        @version = T.let(@version, T.nilable(String))
        @version ||= ENV.fetch("APP_VERSION", nil)
        @version ||= ENV.fetch("GIT_SHA", nil)
        @version ||= T.must(
          `command -v git && git rev-parse --short HEAD`.to_s.split("\n").last,
        ).freeze # localhost
      end

      #
      # Returns ENV["RACK_ENV"] or "development" if it is not set
      #
      sig { returns(String) }
      def environment
        ENV.fetch("RACK_ENV", "development")
      end

      #
      # Returns the name of the database based on the app name and the environment,
      # e.g. "myapp_development"
      #
      sig { returns(String) }
      def default_db_name
        @default_db_name ||= T.let("#{config.app_name}_#{environment}".freeze, T.nilable(String))
      end

      #
      # Returns the database URL based on the DATABASE_URL environment variable or
      # a default value based on the default_db_name
      #
      sig { returns(String) }
      def default_db_url
        @default_db_url ||= T.let(
          ENV.fetch("DATABASE_URL", "postgresql://localhost:5432/#{default_db_name}"),
          T.nilable(String),
        )
      end

      sig { returns(Sequel::Database) }
      def raw_db_connection
        @raw_db_connection = T.let(@raw_db_connection, T.nilable(Sequel::Database))
        return @raw_db_connection unless @raw_db_connection.nil?

        # calling "Sequel.connect" creates a new connection
        @raw_db_connection = Sequel.connect(AppBase.config.db_url || default_db_url)

        config.db_extensions.each do |ext|
          T.cast(@raw_db_connection, Sequel::Database).extension(ext)
        end

        if config.db_extensions.include?(:pg_json)
          # https://github.com/jeremyevans/sequel/blob/5.75.0/lib/sequel/extensions/pg_json.rb#L8
          @raw_db_connection.wrap_json_primitives = true
        end

        @raw_db_connection
      end
    end
  end
end
