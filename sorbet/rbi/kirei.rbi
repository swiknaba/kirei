# typed: true
# rubocop:disable all

APP_ROOT = T.type_alias { String }

module Kirei
  module BaseModel
    sig { returns(String) }
    def name; end
  end
end

# rubocop:enable all
