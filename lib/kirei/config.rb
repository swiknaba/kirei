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

    # dup to allow the user to extend the existing list of sensitive keys
    prop :sensitive_keys, T::Array[Regexp], factory: -> { SENSITIVE_KEYS.dup }

    prop :app_name, String, default: "kirei"

    # must use "pg_json" to parse jsonb columns to hashes
    #
    # Source: https://github.com/jeremyevans/sequel/blob/5.75.0/lib/sequel/extensions/pg_json.rb
    prop :db_extensions, T::Array[Symbol], default: %i[pg_json pg_array]
    prop :db_url, T.nilable(String)
    # Extra or unknown properties present in the Hash do not raise exceptions at runtime
    # unless the optional strict argument to from_hash is passed
    #
    # Source: https://sorbet.org/docs/tstruct#from_hash-gotchas
    prop :db_strict_type_resolving, T.nilable(T::Boolean), default: nil

    prop :allowed_origins, T::Array[String], default: []
  end
end
