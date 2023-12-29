# typed: strict
# frozen_string_literal: true

module Kirei
  class AppBase < ::Sinatra::Base
    class << self
      extend T::Sig

      # convenience method since "Kirei.configuration" must be nilable since it is nil
      # at the beginning of initilization of the app
      sig { returns(Kirei::Config) }
      def config
        T.must(Kirei.configuration)
      end

      sig { returns(Pathname) }
      def root
        defined?(::APP_ROOT) ? Pathname.new(::APP_ROOT) : Pathname.new(Dir.pwd)
      end

      sig { returns(String) }
      def version
        @version = T.let(@version, T.nilable(String))
        @version ||= ENV.fetch("APP_VERSION", nil)
        @version ||= ENV.fetch("GIT_SHA", nil)
        @version ||= T.must(
          `command -v git && git rev-parse --short HEAD`.to_s.split("\n").last,
        ).freeze # localhost
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
        @raw_db_connection = T.let(@raw_db_connection, T.nilable(Sequel::Database))
        return @raw_db_connection unless @raw_db_connection.nil?

        # calling "Sequel.connect" creates a new connection
        @raw_db_connection = Sequel.connect(default_db_url)

        config.db_extensions.each do |ext|
          @raw_db_connection.extension(ext)
        end

        @raw_db_connection
      end
    end
  end
end
