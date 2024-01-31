# typed: strict
# frozen_string_literal: true

module Kirei
  module Middleware
    # https://github.com/rack/rack/blob/main/UPGRADE-GUIDE.md#rack-3-upgrade-guide
    RackResponseType = T.type_alias do
      [
        Integer,
        T::Hash[String, String], # in theory, the values are allowed to be arrays of integers for binary representations
        T.any(T::Array[String], Proc),
      ]
    end

    RackEnvType = T.type_alias { T::Hash[String, String] }
  end
end
