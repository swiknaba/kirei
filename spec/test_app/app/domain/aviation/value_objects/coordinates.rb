# typed: strict
# frozen_string_literal: true

#
# a = Aviation::ValueObjects::Coordinates.new(latitude: 123.314, longitude: 113.24, locations: ["Munich", "Berlin"])
# b = Aviation::ValueObjects::Coordinates.new(latitude: 123.314, longitude: 113.24, locations: ["Berlin", "Munich", "Berlin"])
#
# a.equal_with_array_mode?(b, array_mode: Kirei::Services::CompareArray::Mode::STRICT)
#   => false
#
# a.equal_with_array_mode?(b, array_mode: Kirei::Services::CompareArray::Mode::IGNORE_ORDER)
#   => false
#
# a.equal_with_array_mode?(b, array_mode: Kirei::Services::CompareArray::Mode::IGNORE_ORDER_AND_DUPLICATES)
#   => true
#

module Aviation
  module ValueObjects
    class Coordinates < T::Struct
      extend T::Sig
      include Kirei::Domain::ValueObject

      const :latitude, Float
      const :longitude, Float

      const :locations, T::Array[String], default: []

      sig { returns(String) }
      def to_s
        "#{latitude},#{longitude}"
      end
    end
  end
end
