# typed: strict
# frozen_string_literal: true

module Kirei
  class Controller < Routing::Base
    class << self
      extend T::Sig

      sig { returns(Routing::NilableHooksType) }
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
      @before_hooks ||= T.let(Set.new, Routing::NilableHooksType)
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
      @after_hooks ||= T.let(Set.new, Routing::NilableHooksType)
      @after_hooks.add(block) if block
    end

    sig { returns(Routing::Request) }
    def request
      @request ||= T.let(Routing::Request.new(env: env), T.nilable(Routing::Request))
    end

    sig { returns(T::Hash[String, T.untyped]) }
    private def env
      T.cast(@router.current_env, T::Hash[String, T.untyped])
    end
  end
end
