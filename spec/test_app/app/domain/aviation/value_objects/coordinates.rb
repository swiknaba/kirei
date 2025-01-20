# typed: strict
# frozen_string_literal: true

module Aviation
  module ValueObjects
    class Coordinates < T::Struct
      extend T::Sig
      include Kirei::Domain::ValueObject

      const :latitude, Float
      const :longitude, Float

      sig { returns(String) }
      def to_s
        "#{latitude},#{longitude}"
      end
    end
  end
end
