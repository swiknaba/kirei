# typed: strict
# frozen_string_literal: true

class Airport < T::Struct
  extend T::Sig
  include Kirei::BaseModel

  const :id, String
  const :name, String
end
