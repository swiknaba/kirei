# typed: false

module Kirei
  module BaseModel
    extend T::Sig
    extend T::Helpers

    sig { returns(BaseClassInterface) }
    def class; super; end # rubocop:disable all

    # An update keeps the original object intact, and returns a new object with the updated values.
    sig do
      params(
        hash: T::Hash[Symbol, T.untyped],
      ).returns(T.self_type)
    end
    def update(hash)
      self.class.db.where({ id: id }).update(hash)
      self.class.find_by({ id: id })
    end

    module BaseClassInterface
      extend T::Sig
      extend T::Helpers
      interface!

      sig { abstract.params(hash: T.untyped).returns(T.untyped) }
      def find_by(hash)
      end

      sig { abstract.params(hash: T.untyped).returns(T.untyped) }
      def where(hash)
      end

      sig { abstract.params(hash: T.untyped).returns(T.untyped) }
      def resolve(hash)
      end

      sig { abstract.params(hash: T.untyped).returns(T.untyped) }
      def resolve_first(hash)
      end

      sig { abstract.returns(T.untyped) }
      def table_name
      end

      sig { abstract.returns(T.untyped) }
      def db
      end
    end

    module ClassMethods
      extend T::Sig
      extend T::Generic

      # the attached class is the class that extends this module
      # e.g. "User"
      # extend T::Generic
      # has_attached_class!
      has_attached_class!

      include BaseClassInterface

      sig { override.returns(String) }
      def table_name
        T.must(name.split("::").last).pluralize.underscore
      end

      sig { override.returns(Sequel::Dataset) }
      def db
        Kirei.raw_db_connection[table_name.to_sym]
      end

      sig do
        override.params(
          hash: T::Hash[Symbol, T.untyped],
        ).returns(T::Array[T.attached_class])
      end
      def where(hash)
        resolve(db.where(hash))
      end

      sig do
        override.params(
          hash: T::Hash[Symbol, T.untyped],
        ).returns(T.nilable(T.attached_class))
      end
      def find_by(hash)
        resolve_first(db.where(hash))
      end

      # Extra or unknown properties present in the Hash do not raise exceptions at
      # runtime unless the optional strict argument to from_hash is passed
      #
      # Source: https://sorbet.org/docs/tstruct#from_hash-gotchas
      # "strict" defaults to "false".
      sig do
        override.params(
          query: Sequel::Dataset,
          strict: T.nilable(T::Boolean),
        ).returns(T::Array[T.attached_class])
      end
      def resolve(query, strict = nil)
        strict_loading = strict.nil? ? Kirei.config.db_strict_type_resolving : strict

        query.map do |row|
          row = T.cast(row, T::Hash[Symbol, T.untyped])
          row.stringify_keys! # sequel returns symbolized keys
          from_hash(row, strict_loading)
        end
      end

      sig do
        override.params(
          query: Sequel::Dataset,
          strict: T.nilable(T::Boolean),
        ).returns(T.nilable(T.attached_class))
      end
      def resolve_first(query, strict = nil)
        resolve(query.limit(1), strict).first
      end
    end

    mixes_in_class_methods(ClassMethods)
  end
end
