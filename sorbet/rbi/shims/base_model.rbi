# typed: true

# rubocop:disable Style/EmptyMethod
module Kirei
  module BaseModel
    include Kernel # "self" is a class since we include the module in a class
    include T::Props::Serializable

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
