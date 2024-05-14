# typed: strict
# frozen_string_literal: true

module Kirei
  # rubocop:disable Metrics

  #
  # Example Usage:
  #
  #    Kirei::Logging::Logger.call(
  #      level: :info,
  #      label: "Request started",
  #      meta: {
  #        key: "value",
  #      },
  #    )
  #
  # You can define a custom log transformer to transform the logline:
  #
  #    Kirei::App.config.log_transformer = Proc.new { _1 }
  #
  # By default, "meta" is flattened, and sensitive values are masked using see `Kirei::App.config.sensitive_keys`.
  # You can also build on top of the provided log transformer:
  #
  #   Kirei::App.config.log_transformer = Proc.new do |meta|
  #      flattened_meta = Kirei::Logging::Logger.flatten_hash_and_mask_sensitive_values(meta)
  #      # Do something with the flattened meta
  #      flattened_meta.map { _1.to_json }
  #   end
  #
  # NOTE:
  #    * The log transformer must return an array of strings to allow emitting multiple lines per log event.
  #    * When ever possible, key names follow OpenTelemetry Semantic Conventions, https://opentelemetry.io/docs/concepts/semantic-conventions/
  #
  module Logging
    class Logger
      extend T::Sig

      FILTERED = "[FILTERED]"

      @instance = T.let(nil, T.nilable(Kirei::Logging::Logger))

      sig { void }
      def initialize
        super
        @queue = T.let(Thread::Queue.new, Thread::Queue)
        @thread = T.let(start_logging_thread, Thread)
      end

      sig { returns(Kirei::Logging::Logger) }
      def self.instance
        @instance ||= new
      end

      sig { returns(::Logger) }
      def self.logger
        return @logger unless @logger.nil?

        @logger = T.let(nil, T.nilable(::Logger))
        @logger ||= ::Logger.new($stdout)

        # we want the logline to be parseable to JSON
        @logger.formatter = proc do |_severity, _datetime, _progname, msg|
          "#{msg}\n"
        end

        @logger
      end

      sig do
        params(
          level: Logging::Level,
          label: String,
          meta: T::Hash[String, T.untyped],
        ).void
      end
      def self.call(level:, label:, meta: {})
        return if ENV["NO_LOGS"] == "true"
        return if level.serialize < App.config.log_level.serialize

        # must extract data from current thread before passing this down to the logging thread
        meta["enduser.id"] ||= Thread.current[:enduser_id] # OpenTelemetry::SemanticConventions::Trace::ENDUSER_ID
        meta["service.instance.id"] ||= Thread.current[:request_id] # OpenTelemetry::SemanticConventions::Resource::SERVICE_INSTANCE_ID

        instance.call(level: level, label: label, meta: meta)
      end

      sig do
        params(
          level: Logging::Level,
          label: String,
          meta: T::Hash[String, T.untyped],
        ).void
      end
      def call(level:, label:, meta: {})
        Kirei::App.config.log_default_metadata.each_pair do |key, value|
          meta[key] ||= value
        end

        meta["service.name"] ||= Kirei::App.config.app_name # OpenTelemetry::SemanticConventions::Resource::SERVICE_NAME
        meta["service.version"] = Kirei::App.version # OpenTelemetry::SemanticConventions::Resource::SERVICE_VERSION
        meta["timestamp"] ||= Time.now.utc.iso8601
        meta["level"] ||= level.to_human
        meta["label"] ||= label

        @queue << meta
      end

      sig { returns(Thread) }
      def start_logging_thread
        Thread.new do
          Kernel.loop do
            log_data = T.let(@queue.pop, T::Hash[Symbol, T.untyped])
            log_transformer = App.config.log_transformer

            loglines = if log_transformer
              log_transformer.call(log_data)
            else
              [Oj.dump(
                Kirei::Logging::Logger.flatten_hash_and_mask_sensitive_values(log_data),
                Kirei::OJ_OPTIONS,
              )]
            end

            loglines.each { Kirei::Logging::Logger.logger.unknown(_1) }
          end
        end
      end

      # rubocop:disable Naming/MethodParameterName
      sig do
        params(
          k: String,
          v: String,
        ).returns(String)
      end
      def self.mask(k, v)
        App.config.sensitive_keys.any? { k.match?(_1) } ? FILTERED : v
      end
      # rubocop:enable Naming/MethodParameterName

      sig do
        params(
          hash: T::Hash[T.any(Symbol, String), T.untyped],
          prefix: String,
        ).returns(T::Hash[String, T.untyped])
      end
      def self.flatten_hash_and_mask_sensitive_values(hash, prefix = "")
        result = T.let({}, T::Hash[String, T.untyped])
        Kirei::Helpers.deep_stringify_keys!(hash)
        hash = T.cast(hash, T::Hash[String, T.untyped])

        hash.each do |key, value|
          new_prefix = Kirei::Helpers.blank?(prefix) ? key : "#{prefix}.#{key}"

          case value
          when Hash
            # Some libraries have a custom Hash class that inhert from Hash, but act differently, e.g. OmniAuth::AuthHash.
            # This results in `transform_keys` being available but without any effect.
            value = value.to_h if value.class != Hash
            result.merge!(flatten_hash_and_mask_sensitive_values(value.transform_keys(&:to_s), new_prefix))
          when Array
            value.each_with_index do |element, index|
              if element.is_a?(Hash) || element.is_a?(Array)
                result.merge!(flatten_hash_and_mask_sensitive_values({ index => element }, new_prefix))
              else
                result["#{new_prefix}.#{index}"] = element.is_a?(String) ? mask(key, element) : element
              end
            end
          when String then result[new_prefix] = mask(key, value)
          when Numeric, FalseClass, TrueClass, NilClass then result[new_prefix] = value
          else
            if value.respond_to?(:serialize)
              serialized_value = value.serialize
              if serialized_value.is_a?(Hash)
                result.merge!(
                  flatten_hash_and_mask_sensitive_values(serialized_value.transform_keys(&:to_s), new_prefix),
                )
              else
                result[new_prefix] = serialized_value&.to_s
              end
            else
              result[new_prefix] = value&.to_s
            end
          end
        end

        result
      end
    end
    # rubocop:enable Metrics
  end
end
