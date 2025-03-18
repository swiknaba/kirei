# typed: strict
# frozen_string_literal: true

module Kirei
  module Domain
    module ValueObject
      extend T::Sig
      extend T::Helpers

      sig { returns(T.class_of(T::Struct)) }
      def class; super; end # rubocop:disable all

      sig { params(other: T.untyped).returns(T::Boolean) }
      def ==(other)
        return false unless instance_of?(other.class)

        instance_variables.all? do |var|
          instance_variable_get(var) == other.instance_variable_get(var)
        end
      end

      sig do
        params(
          other: T.untyped,
          array_mode: Kirei::Services::ArrayComparison::Mode,
        ).returns(T::Boolean)
      end
      def equal_with_array_mode?(other, array_mode: Kirei::Services::ArrayComparison::Mode::STRICT)
        return false unless instance_of?(other.class)

        instance_variables.all? do |var|
          one = instance_variable_get(var)
          two = other.instance_variable_get(var)
          next one == two unless one.is_a?(Array)

          Kirei::Services::ArrayComparison.call(one, two, mode: array_mode)
        end
      end
    end
  end
end
