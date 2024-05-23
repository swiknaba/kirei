# typed: strict
# frozen_string_literal: true

module Kirei
  module Services
    class Runner
      extend T::Sig
      extend T::Generic

      sig do
        type_parameters(:T)
          .params(
            class_name: T.untyped,
            log_tags: T::Hash[String, T.untyped],
            block: T.proc.returns(T.type_parameter(:T)),
          ).returns(T.type_parameter(:T))
      end
      def self.call(class_name, log_tags: {}, &block)
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
        service = yield

        service
      ensure
        stop = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
        latency_in_ms = stop - T.must(start)

        result = case service
                 when Services::Result
                   service.success? ? "success" : "failure"
                 else
                   "unknown"
        end

        metric_tags = Logging::Metric.inject_defaults({ "service.result" => result })
        ::StatsD.measure(class_name, latency_in_ms, tags: metric_tags)

        logtags = {
          "service.name" => class_name.to_s,
          "service.latency_in_ms" => latency_in_ms,
          "service.result" => result,
          "service.source_location" => source_location(block),
        }
        logtags.merge!(log_tags)

        Logging::Logger.call(level: Logging::Level::INFO, label: "Service Finished", meta: logtags)
      end

      sig { params(proc: T.proc.returns(T.untyped)).returns(String) }
      private_class_method def self.source_location(proc)
        proc.source_location.join(":").gsub(App.root.to_s, "")
      end
    end
  end
end
