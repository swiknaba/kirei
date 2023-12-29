# # typed: true

# # rubocop:disable Style/EmptyMethod
# module Kirei
#   module BaseModel
#     include T::Props::Serializable::ClassMethods
#   end

#   module BaseModelClass
#     include BaseModel
#     mixes_in_class_methods(BaseModel::ClassMethods)
#   end

#   module BaseModel
#     # module InstanceMethods
#       sig { returns(T.class_of(BaseModelClass)) }
#       def class; end

#       sig { returns(T.any(String, Integer)) }
#       def id; end
#     end
#   # end
# end
# # rubocop:enable Style/EmptyMethod
