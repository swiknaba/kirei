# typed: strict
# frozen_string_literal: true

module Kirei
  #
  # Add `extend Kirei::BaseModel` to your models.
  #
  module BaseModel
    extend T::Sig

    sig { returns(String) }
    def table_name
      T.must(name.split("::").last).pluralize.underscore
    end
  end
end
