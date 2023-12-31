# typed: strict
# frozen_string_literal: true

module Kirei
  # rubocop:disable Metrics

  #
  # Example Usage:
  #
  #    Kirei::Logger.call(
  #      level: :info,
  #      label: "Request started",
  #      meta: {
  #        key: "value",
  #      },
  #    )
  #
  # You can define a custom log transformer to transform the logline:
  #
  #    Kirei::AppBase.config.log_transformer = Proc.new { _1 }
  #
  # By default, "meta" is flattened, and sensitive values are masked using see `Kirei::AppBase.config.sensitive_keys`.
  # You can also build on top of the provided log transformer:
  #
  #   Kirei::AppBase.config.log_transformer = Proc.new do |meta|
  #      flattened_meta = Kirei::Logger.flatten_hash_and_mask_sensitive_values(meta)
  #      # Do something with the flattened meta
  #      flattened_meta.map { _1.to_json }
  #   end
  #
  # NOTE: The log transformer must return an array of strings to allow emitting multiple lines per log event.
  #
  class Logger < Kirei::Base
    FILTERED = "[FILTERED]"

    @instance = T.let(nil, T.nilable(Kirei::Logger))

    sig { void }
    def initialize
      super
      @queue = T.let(Thread::Queue.new, Thread::Queue)
      @thread = T.let(start_logging_thread, Thread)
    end

    sig { returns(Kirei::Logger) }
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
        level: T.any(String, Symbol),
        label: String,
        meta: T::Hash[Symbol, T.untyped],
      ).void
    end
    def self.call(level:, label:, meta: {})
      return if ENV["LOGGER"] == "disabled"

      instance.call(level: level, label: label, meta: meta)
    end

    sig do
      params(
        level: T.any(String, Symbol),
        label: String,
        meta: T::Hash[Symbol, T.untyped],
      ).void
    end
    def call(level:, label:, meta: {})
      Kirei::AppBase.config.log_default_metadata.each_pair do |key, value|
        meta[key] ||= value
      end

      #
      # key names follow OpenTelemetry Semantic Conventions
      # Source: https://opentelemetry.io/docs/concepts/semantic-conventions/
      #
      meta[:"service.instance.id"] ||= Thread.current[:request_id]
      meta[:"service.name"] ||= Kirei::AppBase.config.app_name

      # The Ruby logger only accepts one string as the only argument
      @queue << { level: level, label: label, meta: meta }
    end

    sig { returns(Thread) }
    def start_logging_thread
      Thread.new do
        Kernel.loop do
          log_data = T.let(@queue.pop, T::Hash[Symbol, T.untyped])
          level = log_data.fetch(:level)
          label = log_data.fetch(:label)
          meta = T.let(log_data.fetch(:meta), T::Hash[Symbol, T.untyped])
          meta[:"service.version"] ||= Kirei::AppBase.version
          meta[:timestamp] ||= Time.now.utc.iso8601
          meta[:level] ||= level.to_s.upcase
          meta[:label] ||= label

          log_transformer = AppBase.config.log_transformer

          loglines = if log_transformer
            log_transformer.call(meta)
          else
            [Oj.dump(Kirei::Logger.flatten_hash_and_mask_sensitive_values(meta))]
          end

          loglines.each { Kirei::Logger.logger.error(_1) }
        end
      end
    end

    # rubocop:disable Naming/MethodParameterName
    sig do
      params(
        k: Symbol,
        v: String,
      ).returns(String)
    end
    def self.mask(k, v)
      return Kirei::Logger::FILTERED if AppBase.config.sensitive_keys.any? { k.match?(_1) }

      v
    end
    # rubocop:enable Naming/MethodParameterName

    sig do
      params(
        hash: T::Hash[Symbol, T.untyped],
        prefix: Symbol,
      ).returns(T::Hash[Symbol, T.untyped])
    end
    def self.flatten_hash_and_mask_sensitive_values(hash, prefix = :'')
      result = T.let({}, T::Hash[Symbol, T.untyped])
      Kirei::Helpers.deep_symbolize_keys!(hash)

      hash.each do |key, value|
        new_prefix = Kirei::Helpers.blank?(prefix) ? key : :"#{prefix}.#{key}"

        case value
        when Hash then result.merge!(flatten_hash_and_mask_sensitive_values(value.transform_keys(&:to_sym), new_prefix))
        when Array
          value.each_with_index do |element, index|
            if element.is_a?(Hash) || element.is_a?(Array)
              result.merge!(flatten_hash_and_mask_sensitive_values({ index => element }, new_prefix))
            else
              result[:"#{new_prefix}.#{index}"] = element.is_a?(String) ? mask(key, element) : element
            end
          end
        when String then result[new_prefix] = mask(key, value)
        when Numeric, FalseClass, TrueClass, NilClass then result[new_prefix] = value
        else
          if value.respond_to?(:serialize)
            serialized_value = value.serialize
            if serialized_value.is_a?(Hash)
              result.merge!(
                flatten_hash_and_mask_sensitive_values(serialized_value.transform_keys(&:to_sym), new_prefix),
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
