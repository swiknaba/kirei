# typed: strict
# frozen_string_literal: true

module Kirei
  module Model
    class HumanIdGenerator
      extend T::Sig

      # Removed ambiguous characters 0, 1, O, I, l, 5, S
      ALLOWED_CHARS = "2346789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrtuvwxyz"
      private_constant :ALLOWED_CHARS

      ALLOWED_CHARS_COUNT = T.let(ALLOWED_CHARS.size, Integer)
      private_constant :ALLOWED_CHARS_COUNT

      sig do
        params(
          length: Integer,
          prefix: String,
        ).returns(String)
      end
      def self.call(length:, prefix:)
        "#{prefix}_#{random_id(length)}"
      end

      sig { params(key_length: Integer).returns(String) }
      private_class_method def self.random_id(key_length)
        random_chars = Array.new(key_length)

        key_length.times do |idx|
          random_char_idx = SecureRandom.random_number(ALLOWED_CHARS_COUNT)
          random_char = T.must(ALLOWED_CHARS[random_char_idx])
          random_chars[idx] = random_char
        end

        random_chars.join
      end
    end
  end
end
