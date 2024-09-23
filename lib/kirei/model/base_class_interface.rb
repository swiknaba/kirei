# typed: strict
# frozen_string_literal: true

# rubocop:disable Style/EmptyMethod

module Kirei
  module Model
    module BaseClassInterface
      extend T::Sig
      extend T::Helpers
      interface!

      sig { abstract.params(hash: T.untyped).returns(T.untyped) }
      def find_by(hash); end

      sig { abstract.params(hash: T.untyped).returns(T.untyped) }
      def where(hash); end

      sig { abstract.returns(T.untyped) }
      def all; end

      sig { abstract.params(hash: T.untyped).returns(T.untyped) }
      def create(hash); end

      sig { abstract.params(attributes: T.untyped).void }
      def wrap_jsonb_non_primivitives!(attributes); end

      sig { abstract.params(hash: T.untyped).returns(T.untyped) }
      def resolve(hash); end

      sig { abstract.params(hash: T.untyped).returns(T.untyped) }
      def resolve_first(hash); end

      sig { abstract.returns(T.untyped) }
      def table_name; end

      sig { abstract.returns(T.untyped) }
      def query; end

      sig { abstract.returns(T.untyped) }
      def db; end

      sig { abstract.params(sql: T.untyped, params: T.untyped).returns(T.untyped) }
      def exec_sql(sql, params); end

      sig { abstract.returns(T.untyped) }
      def human_id_length; end

      sig { abstract.returns(T.untyped) }
      def human_id_prefix; end

      sig { abstract.returns(T.untyped) }
      def generate_human_id; end
    end
  end
end

# rubocop:enable Style/EmptyMethod
