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
        return false unless other.class == self.class

        instance_variables.all? do |var|
          instance_variable_get(var) == other.instance_variable_get(var)
        end
      end
    end
  end
end
