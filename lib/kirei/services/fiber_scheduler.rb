# typed: strict
# frozen_string_literal: true

module Kirei
  module Services
    #
    # https://ruby-doc.org/core-3.0.0/Fiber/SchedulerInterface.html
    #
    class FiberScheduler
      extend T::Sig

      sig { void }
      def initialize
        @tasks = T.let([], T::Array[AsyncRunner::TaskType])
        @blocked_fibers = T.let({}, T::Hash[T.untyped, Fiber])
        @mutex = T.let(Mutex.new, Mutex)
      end

      sig { params(block: T.proc.returns(T.untyped)).void }
      def schedule(&block)
        @mutex.synchronize do
          @tasks << block
        end
      end

      sig { void }
      def run
        while @tasks.any?
          task = @mutex.synchronize { @tasks.shift }
          begin
            task&.call
          rescue StandardError => e
            # TODO
            puts "Error executing task: #{e.message}"
          end
        end
      end

      sig { void }
      def close
        run
      end

      sig do
        params(
          _io: T.untyped,
          _events: T.untyped,
          _timeout: T.untyped,
        ).returns(T.untyped)
      end
      def io_wait(_io, _events, _timeout)
        Fiber.yield
      end

      sig { params(pid: Integer, flags: Integer).returns(Object) }
      def process_wait(pid, flags)
        Thread.new do
          Process::Status.wait(pid, flags)
        end.value
      end

      sig { params(_duration: T.untyped).returns(T.untyped) }
      def kernel_sleep(_duration)
        Fiber.yield
      end

      sig { params(blocker: T.untyped, timeout: T.nilable(Float)).returns(T::Boolean) }
      def block(blocker, timeout = nil)
        fiber = T.unsafe(Fiber).current # .current exists within the context of a Ractor
        @mutex.synchronize do
          @blocked_fibers[blocker] = fiber
        end

        if timeout
          Thread.new do
            sleep(timeout)
            unblock(blocker, fiber)
          end
        end

        Fiber.yield
        true
      end

      sig { params(blocker: T.untyped, fiber: Fiber).void }
      def unblock(blocker, fiber)
        @mutex.synchronize do
          schedule { fiber.resume } if @blocked_fibers.delete(blocker) == fiber
        end
      end
    end
  end
end
