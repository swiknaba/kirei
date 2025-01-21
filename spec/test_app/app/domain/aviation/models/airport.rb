# typed: strict
# frozen_string_literal: true

# == Schema Info
#
# Table name: airports
#
#  id                  :text                not null, primary key
#  name                :text                not null
#  latitude            :double precision    not null
#  longitude           :double precision    not null
#

module Aviation
  module Models
    class Airport < T::Struct
      extend T::Sig
      include Kirei::Model

      sig { override.returns(Integer) }
      def self.human_id_length = 12

      const :id, String
      const :name, String
      const :latitude, Float
      const :longitude, Float
    end
  end
end
