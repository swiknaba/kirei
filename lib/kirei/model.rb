# typed: strict
# frozen_string_literal: true

module Kirei
  module Model
    extend T::Sig
    extend T::Helpers

    sig { returns(Kirei::Model::BaseClassInterface) }
    def class; super; end # rubocop:disable all

    # An update keeps the original object intact, and returns a new object with the updated values.
    sig do
      params(
        hash: T::Hash[Symbol, T.untyped],
      ).returns(T.self_type)
    end
    def update(hash)
      hash[:updated_at] = Time.now.utc if respond_to?(:updated_at) && hash[:updated_at].nil?
      self.class.wrap_jsonb_non_primivitives!(hash)
      self.class.query.where({ id: id }).update(hash)
      self.class.find_by({ id: id })
    end

    # Delete keeps the original object intact. Returns true if the record was deleted.
    # Calling delete multiple times will return false after the first (successful) call.
    sig { returns(T::Boolean) }
    def delete
      count = self.class.query.where({ id: id }).delete
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

    mixes_in_class_methods(Kirei::Model::ClassMethods)
  end
end
