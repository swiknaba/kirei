# typed: strict
# frozen_string_literal: true

module Kirei
  module Services
    class AsyncRunner
      extend T::Sig

      TaskType = T.type_alias { T.proc.returns(T.untyped) }
      # maybe force people to use the "Result" class
      ResultType = T.type_alias { T::Hash[String, T.untyped] }

      sig { void }
      def initialize
        @task_queue = T.let(Queue.new, Thread::Queue)
        @results = T.let({}, ResultType)
        @result_ractor = T.let(process_services_async, Ractor)
      end

      sig do
        params(
          block: TaskType,
        ).returns(String)
      end
      def call(&block)
        uuid = SecureRandom.uuid

        @task_queue << [uuid, block]

        uuid
      end

      sig { void }
      def wait_until_finished
        # we treat a "nil" object as the kill signal for the processing loop
        @task_queue << nil
        @result_ractor.take
      rescue Ractor::ClosedError => e
        App.config.logger.error("Ractor error: #{e.message}")
      end

      sig { returns(Ractor) }
      private def process_services_async
        ractor = Ractor.new do
          set_scheduler

          task_queue, results = T.let(
            Ractor.receive,
            [Thread::Queue, ResultType],
          )

          fibers = T.let([], T::Array[Fiber])

          loop do
            task = T.let(task_queue.pop, T.nilable([String, TaskType]))
            if task.nil?
              # ensure we finish all started fibers before we exit from the loop
              # which is triggered by sending a "nil" Object to the task queue
              resume_fibers(fibers)
              break
            end

            fiber = process_task(task, results)

            fibers << fiber
          end
        end

        ractor.send([@task_queue, @results])

        ractor
      end

      sig { params(fibers: T::Array[Fiber]).void }
      private def resume_fibers(fibers)
        fibers.each { |fiber| fiber.resume while fiber.alive? }
      end

      sig { params(task: [String, TaskType], results: ResultType).returns(Fiber) }
      private def process_task(task, results)
        uuid, service = task
        Fiber.new(blocking: false) do
          result = service.call
          results[uuid] = result
        rescue StandardError => e
          results[uuid] = { error: e.message, exception: e }
        end
      end

      sig { void }
      private def set_scheduler
        Fiber.set_scheduler(FiberScheduler.new)
      end
    end
  end
end
