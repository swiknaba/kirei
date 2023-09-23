# typed: strict
# frozen_string_literal: true

module Kirei
  class BaseRelation < ROM::Relation
    extend T::Sig

    sig { returns(ROM::Container) }
    def self.connection
      @connection ||= T.let(
        ROM.container(:sql, Kirei.config.db_url) do |config|
          # https://rom-rb.org/4.0/learn/advanced/explicit-setup/#auto-registration
          config.auto_registration("/lib/relations") # naming of relation klass!
          # rel = self.class.name.pluralize.lowercase.to_sym
          # config.relation(rel) do
          #   schema(rel, infer: true)
          # end
        end,
        T.nilable(ROM::Container),
      )
    end
  end
end
