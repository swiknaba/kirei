# typed: true

# rubocop:disable Style/EmptyMethod
module Kirei
  module BaseModel
    sig { returns(T.any(String, Integer)) }
    def id; end

    module ClassMethods
      include T::Props::Serializable::ClassMethods

      sig { returns(String) }
      def name; end
    end

    module BaseClassInterface
      # include T::Props::Serializable::ClassMethods
    end
  end
end
# rubocop:enable Style/EmptyMethod
