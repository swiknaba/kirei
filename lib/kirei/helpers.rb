# typed: strict
# frozen_string_literal: true

module Kirei
  module Helpers
    class << self
      extend T::Sig

      # Simplified version from Rails' ActiveSupport::Inflector#underscore
      sig { params(string: String).returns(String) }
      def underscore(string)
        string.gsub!(/([A-Z])(?=[A-Z][a-z])|([a-z\d])(?=[A-Z])/) do
          T.must((::Regexp.last_match(1) || ::Regexp.last_match(2))) << "_"
        end
        string.tr!("-", "_")
        string.downcase!
        string
      end

      # Simplified version from Rails' ActiveSupport
      sig { params(string: T.any(String, Symbol)).returns(T::Boolean) }
      def blank?(string)
        string.nil? || string.to_s.empty?
      end

      # Simplified version from Rails' ActiveSupport
      sig do
        params(
          object: T.untyped, # could be anything due to recursive calls
          block: Proc,
        ).returns(T.untyped) # could be anything due to recursive calls
      end
      def deep_transform_keys(object, &block)
        case object
        when Hash
          object.each_with_object({}) do |(key, value), result|
            result[yield(key)] = deep_transform_keys(value, &block)
          end
        when Array
          object.map { |e| deep_transform_keys(e, &block) }
        else
          object
        end
      end

      sig do
        params(
          object: T.untyped, # could be anything due to recursive calls
          block: Proc,
        ).returns(T.untyped) # could be anything due to recursive calls
      end
      def deep_transform_keys!(object, &block)
        case object
        when Hash
          # using `each_key` results in a `RuntimeError: can't add a new key into hash during iteration`
          # which is, because the receiver here does not necessarily have a `Hash` type
          object.keys.each do |key| # rubocop:disable Style/HashEachMethods
            value = object.delete(key)
            object[yield(key)] = deep_transform_keys!(value, &block)
          end
          object
        when Array
          object.map! { |e| deep_transform_keys!(e, &block) }
        else
          object
        end
      end
    end
  end
end
