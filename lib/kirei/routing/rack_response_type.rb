# typed: strict
# frozen_string_literal: true

module Kirei
  module Routing
    # https://github.com/rack/rack/blob/main/UPGRADE-GUIDE.md#rack-3-upgrade-guide
    RackResponseType = T.type_alias do
      [
        Integer,                       # status
        T::Hash[String, String],       # headers. Values may be arrays of integers for binary representations
        T.any(T::Array[String], Proc), # body
      ]
    end
  end
end
