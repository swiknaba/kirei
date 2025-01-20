# typed: strict
# frozen_string_literal: true

module Kirei
  module Domain
    module Entity
      extend T::Sig
      extend T::Helpers

      sig { returns(T.class_of(T::Struct)) }
      def class; super; end # rubocop:disable all

      sig { params(other: T.nilable(Kirei::Domain::Entity)).returns(T::Boolean) }
      def ==(other)
        return false unless other.is_a?(Kirei::Domain::Entity)
        return false unless other.class == self.class

        id == other.id
      end
    end
  end
end
