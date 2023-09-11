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
    # dup to allow the user to extend the existing list of sensitive keys
    prop :sensitive_keys, T::Array[Regexp], factory: -> { SENSITIVE_KEYS.dup }
  end
end
