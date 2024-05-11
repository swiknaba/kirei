# typed: strict
# frozen_string_literal: true

# == Schema Info
#
# Table name: airports
#
#  id                  :text    not null, primary key
#  name                :text    not null
#

class Airport < T::Struct
  extend T::Sig
  include Kirei::BaseModel

  const :id, String
  const :name, String
end
