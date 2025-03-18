# typed: strict
# frozen_string_literal: true

module Kirei
  module Services
    class ArrayComparison
      extend T::Sig

      class Mode < T::Enum
        enums do
          STRICT = new("strict")
          IGNORE_ORDER = new("ignore_order")
          IGNORE_ORDER_AND_DUPLICATES = new("ignore_order_and_duplicates")
        end
      end

      sig do
        params(
          array_one: T::Array[T.untyped],
          array_two: T::Array[T.untyped],
          mode: Mode,
        ).returns(T::Boolean)
      end
      def self.call(array_one, array_two, mode: Mode::STRICT)
        case mode
        when Mode::STRICT then array_one == array_two
        when Mode::IGNORE_ORDER then array_one.sort == array_two.sort
        when Mode::IGNORE_ORDER_AND_DUPLICATES then array_one.to_set == array_two.to_set
        else
          T.absurd(mode)
        end
      end
    end
  end
end
