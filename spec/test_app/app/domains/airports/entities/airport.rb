# typed: strict
# frozen_string_literal: true

module Airports
  module Entities
    class Airport < T::Struct
      include Kirei::Domain::Entity

      const :id, String
      const :name, String
      const :coordinates, Airports::ValueObjects::Coordinates
    end
  end
end
