# typed: true

# rubocop:disable Style/EmptyMethod
module Kirei
  module BaseModel
    include T::Props::Serializable::ClassMethods
  end

  module BaseModelClass
    include BaseModel
    has_attached_class!
  end

  module BaseModel
    module InstanceMethods
      sig { returns(Kirei::BaseModelClass[T.untyped]) }
      def class; end

      sig { returns(T.any(String, Integer)) }
      def id; end
    end
  end
end
# rubocop:enable Style/EmptyMethod
