# typed: strict
# frozen_string_literal: true

module Kirei
  module Logging
    class Metric
      extend T::Sig

      sig do
        params(
          metric_name: String,
          value: Integer,
          tags: T::Hash[String, T.untyped],
        ).void
      end
      def self.call(metric_name, value = 1, tags: {})
        return if ENV["NO_METRICS"] == "true"

        inject_defaults(tags)

        # Do not `compact_blank` tags, since one might want to track empty strings/"false"/NULLs.
        # NOT having any tag doesn't tell the user if the tag was empty or not set at all.
        StatsD.increment(metric_name, value, tags: tags)
      end

      sig { params(tags: T::Hash[String, T.untyped]).void }
      def self.inject_defaults(tags)
        App.config.metric_default_tags.each_pair do |key, default_value|
          tags[key] ||= default_value
        end

        tags["enduser.id"] ||= Thread.current[:enduser_id]
        tags["service.name"] ||= Kirei::App.config.app_name # OpenTelemetry::SemanticConventions::Resource::SERVICE_NAME
        tags["service.version"] = Kirei::App.version # OpenTelemetry::SemanticConventions::Resource::SERVICE_VERSION
      end
    end
  end
end
