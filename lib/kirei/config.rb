# typed: strict
# frozen_string_literal: true

module Kirei
  class Config < T::Struct
    extend T::Sig

    SENSITIVE_KEYS = T.let(
      [
        # address data
        /email|first_name|last_name|full_name|city|country_alpha2|country_name|country|zip_code/,
        # auth data
        /password|password_confirmation|access_token|client_secret|client_secret_ciphertext|client_key|token/,
      ].freeze,
      T::Array[Regexp],
    )

    prop :logger, ::Logger, factory: -> { ::Logger.new($stdout) }
    prop :log_transformer, T.nilable(T.proc.params(msg: T::Hash[Symbol, T.untyped]).returns(T::Array[String]))
    prop :log_default_metadata, T::Hash[String, T.untyped], default: {}
    prop :log_level, Kirei::Logging::Level, default: Kirei::Logging::Level::INFO

    prop :metric_default_tags, T::Hash[String, T.untyped], default: {}
    prop :metrics_backend, Kirei::Metrics::Backend, factory: -> { Kirei::Metrics::LoggingBackend.new }

    # dup to allow the user to extend the existing list of sensitive keys
    prop :sensitive_keys, T::Array[Regexp], factory: -> { SENSITIVE_KEYS.dup }

    prop :app_name, String, default: "kirei"

    # Database extensions are loaded on the connection via `Sequel::Database#extension`.
    # They add behaviour to one database object, e.g. column type parsing.
    #
    # must use "pg_json" to parse jsonb columns to hashes
    #
    # Source: https://github.com/jeremyevans/sequel/blob/5.75.0/lib/sequel/extensions/pg_json.rb
    prop :db_extensions, T::Array[Symbol], default: %i[pg_json pg_array]
    # Global extensions are loaded via `Sequel.extension` before the connection is created.
    # They change Sequel itself, not a database object, e.g. `:fiber_concurrency` switches the
    # concurrency primitive from `Thread.current` to `Fiber.current` for Async/Falcon servers.
    # Loading one on a database object is silently ignored.
    #
    # Source: https://github.com/jeremyevans/sequel/blob/5.75.0/doc/extensions.rdoc
    prop :db_global_extensions, T::Array[Symbol], default: []
    prop :db_url, T.nilable(String)
    # Connection pool bounds passed to `Sequel.connect`. `nil` keeps the Sequel default.
    #
    # Source: https://github.com/jeremyevans/sequel/blob/5.75.0/doc/opening_databases.rdoc
    prop :db_max_connections, T.nilable(Integer)
    prop :db_pool_timeout, T.nilable(Float)
    prop :db_connect_timeout, T.nilable(Integer)
    # SQL statements run on every new connection, e.g. session timeouts.
    prop :db_connect_sqls, T::Array[String], default: []
    # Extra or unknown properties present in the Hash do not raise exceptions at runtime
    # unless the optional strict argument to from_hash is passed
    #
    # Source: https://sorbet.org/docs/tstruct#from_hash-gotchas
    prop :db_strict_type_resolving, T.nilable(T::Boolean), default: nil

    prop :allowed_origins, T::Array[String], default: []

    # Upper bound for JSON and form request bodies, which Kirei buffers in memory.
    # Requests above it get a 413 JSON:API error. `nil` means no limit.
    # Multipart uploads stream to tempfiles via Rack and are not subject to it.
    prop :max_request_body_bytes, T.nilable(Integer), default: nil
  end
end
