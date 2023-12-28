# typed: true

module Kirei
  module BaseModel
    include T::Props::Serializable::ClassMethods
  end

  module BaseModelClass
    include BaseModel
  end

  module BaseModel
    module InstanceMethods
      sig { returns(BaseModelClass) }
      def class; end

      sig { returns(T.any(String, Integer)) }
      def id; end
    end
  end
end
