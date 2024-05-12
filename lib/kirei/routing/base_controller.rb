# typed: strict
# frozen_string_literal: true

module Kirei
  module Routing
    class BaseController < Routing::Base
      class << self
        extend T::Sig

        sig { returns(NilableHooksType) }
        attr_reader :before_hooks, :after_hooks
      end

      extend T::Sig

      #
      # Statements to be executed before every action.
      #
      # In development mode, Rack Reloader might reload this file causing
      # the before hooks to be executed multiple times.
      #
      sig do
        params(
          block: T.nilable(T.proc.void),
        ).void
      end
      def self.before(&block)
        @before_hooks ||= T.let(Set.new, NilableHooksType)
        @before_hooks.add(block) if block
      end

      #
      # Statements to be executed after every action.
      #
      sig do
        params(
          block: T.nilable(T.proc.void),
        ).void
      end
      def self.after(&block)
        @after_hooks ||= T.let(Set.new, NilableHooksType)
        @after_hooks.add(block) if block
      end
    end
  end
end
