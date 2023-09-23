# typed: strict
# frozen_string_literal: true

# todo: write a tapioca compiler for this
module Templates
  class RelationKlass
    extend T::Sig

    sig do
      params(
        klass_name: String,
        table_name: T.nilable(String),
        ).returns(String)
    end
    def self.erb(klass_name, table_name = nil)
      table_name ||= klass_name.pluralize.underscore
      <<~ERB
        module Relations
          class #{klass_name}Relation < Kirei::BaseRelation
            extend T::Sig

            schema(:#{table_name}, infer: true)

            sig do
              params(
                gateway: Symbol,
              ).returns(ROM::Relation)
            end
            def self.repo(gateway: :default)
              ROM::Repository[:#{table_name}].new(
                connection,
                gateway: gateway,
              ).#{table_name}.map_to(Models::#{klass_name})
            end

            sig do
              params(
                args: T::Hash[T.any(String, Symbol), T.untyped],
              ).returns(T.nilable(Models::#{klass_name}))
            end
            def self.find_by(args)
              return if id.blank?

              repo.where(args).one
            end
          end
        end
      ERB
    end
  end
end
