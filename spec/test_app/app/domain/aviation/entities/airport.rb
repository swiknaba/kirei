# typed: strict
# frozen_string_literal: true

module Aviation
  module Entities
    class Airport < T::Struct
      include Kirei::Domain::Entity

      const :id, String
      const :name, String
      const :coordinates, Aviation::ValueObjects::Coordinates
    end
  end
end
