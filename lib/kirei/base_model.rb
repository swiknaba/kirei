# typed: strict
# frozen_string_literal: true

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
      hash[:updated_at] = Time.now.utc if respond_to?(:updated_at) && hash[:updated_at].nil?
      self.class.db.where({ id: id }).update(hash)
      self.class.find_by({ id: id })
    end

    # Delete keeps the original object intact. Returns true if the record was deleted.
    # Calling delete multiple times will return false after the first (successful) call.
    sig { returns(T::Boolean) }
    def delete
      count = self.class.db.where({ id: id }).delete
      count == 1
    end

    # warning: this is not concurrency-safe
    # save keeps the original object intact, and returns a new object with the updated values.
    sig { returns(T.self_type) }
    def save
      previous_record = self.class.find_by({ id: id })

      hash = serialize
      Helpers.deep_symbolize_keys!(hash)
      hash = T.cast(hash, T::Hash[Symbol, T.untyped])

      if previous_record.nil?
        self.class.create(hash)
      else
        update(hash)
      end
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
      def create(hash)
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

      # defaults to a pluralized, underscored version of the class name
      sig { override.returns(String) }
      def table_name
        @table_name ||= T.let(
          begin
            table_name_ = Kirei::Helpers.underscore(T.must(name.split("::").last))
            "#{table_name_}s"
          end,
          T.nilable(String),
        )
      end

      sig { override.returns(Sequel::Dataset) }
      def db
        AppBase.raw_db_connection[table_name.to_sym]
      end

      sig do
        override.params(
          hash: T::Hash[Symbol, T.untyped],
        ).returns(T::Array[T.attached_class])
      end
      def where(hash)
        resolve(db.where(hash))
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      # default values defined in the model are used, if omitted in the hash
      sig do
        override.params(
          hash: T::Hash[Symbol, T.untyped],
        ).returns(T.attached_class)
      end
      def create(hash)
        # instantiate a new object to ensure we use default values defined in the model
        without_id = !hash.key?(:id)
        hash[:id] = "kirei-fake-id" if without_id
        new_record = from_hash(Helpers.deep_stringify_keys(hash))
        all_attributes = T.let(new_record.serialize, T::Hash[String, T.untyped])
        all_attributes.delete("id") if without_id && all_attributes["id"] == "kirei-fake-id"

        # setting `@raw_db_connection.wrap_json_primitives = true`
        # only works on JSON primitives, but not on blank hashes/arrays
        if AppBase.config.db_extensions.include?(:pg_json)
          all_attributes.each_pair do |key, value|
            next unless value.is_a?(Hash) || value.is_a?(Array)

            all_attributes[key] = T.unsafe(Sequel).pg_jsonb_wrap(value)
          end
        end

        if new_record.respond_to?(:created_at) && all_attributes["created_at"].nil?
          all_attributes["created_at"] = Time.now.utc
        end
        if new_record.respond_to?(:updated_at) && all_attributes["updated_at"].nil?
          all_attributes["updated_at"] = Time.now.utc
        end

        pkey = T.let(db.insert(all_attributes), String)

        T.must(find_by({ id: pkey }))
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

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
        strict_loading = strict.nil? ? AppBase.config.db_strict_type_resolving : strict

        query.map do |row|
          row = T.cast(row, T::Hash[Symbol, T.untyped])
          row.transform_keys!(&:to_s) # sequel returns symbolized keys
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
        strict_loading = strict.nil? ? AppBase.config.db_strict_type_resolving : strict

        resolve(query.limit(1), strict_loading).first
      end
    end

    mixes_in_class_methods(ClassMethods)
  end
end
