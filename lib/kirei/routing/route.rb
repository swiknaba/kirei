# typed: strict
# frozen_string_literal: true

module Kirei
  module Routing
    class Route < T::Struct
      const :verb, Verb
      const :path, String
      const :controller, T.class_of(Controller)
      const :action, String
    end
  end
end
