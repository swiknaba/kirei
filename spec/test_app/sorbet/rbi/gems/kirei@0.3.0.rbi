# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `kirei` gem.
# Please instead update this file by running `bin/tapioca gem kirei`.

# source://kirei//lib/kirei.rb#30
module Kirei
  class << self
    # source://kirei//lib/kirei.rb#53
    sig { returns(T.nilable(::Kirei::Config)) }
    def configuration; end

    # @return [Kirei::Config, nil]
    #
    # source://kirei//lib/kirei.rb#53
    def configuration=(_arg0); end

    # @yield [T.must(configuration)]
    #
    # source://kirei//lib/kirei.rb#60
    sig { params(_: T.proc.params(configuration: ::Kirei::Config).void).void }
    def configure(&_); end
  end
end

# This is the entrypoint into the application; it implements the Rack interface.
#
# source://kirei//lib/kirei/app.rb#8
class Kirei::App < ::Kirei::Routing::Base
  class << self
    # convenience method since "Kirei.configuration" must be nilable since it is nil
    # at the beginning of initilization of the app
    #
    # source://kirei//lib/kirei/app.rb#17
    sig { returns(::Kirei::Config) }
    def config; end

    # Returns the name of the database based on the app name and the environment,
    # e.g. "myapp_development"
    #
    # source://kirei//lib/kirei/app.rb#55
    sig { returns(::String) }
    def default_db_name; end

    # Returns the database URL based on the DATABASE_URL environment variable or
    # a default value based on the default_db_name
    #
    # source://kirei//lib/kirei/app.rb#64
    sig { returns(::String) }
    def default_db_url; end

    # Returns ENV["RACK_ENV"] or "development" if it is not set
    #
    # source://kirei//lib/kirei/app.rb#46
    sig { returns(::String) }
    def environment; end

    # source://kirei//lib/kirei/app.rb#72
    sig { returns(::Sequel::Database) }
    def raw_db_connection; end

    # source://kirei//lib/kirei/app.rb#22
    sig { returns(::Pathname) }
    def root; end

    # Returns the version of the app. It checks in the following order:
    # * ENV["APP_VERSION"]
    # * ENV["GIT_SHA"]
    # * `git rev-parse --short HEAD`
    #
    # source://kirei//lib/kirei/app.rb#33
    sig { returns(::String) }
    def version; end
  end
end

# source://kirei//lib/kirei/config.rb#5
class Kirei::Config < ::T::Struct
  prop :logger, ::Logger, default: T.unsafe(nil)
  prop :log_transformer, T.nilable(T.proc.params(msg: T::Hash[::Symbol, T.untyped]).returns(T::Array[::String]))
  prop :log_default_metadata, T::Hash[::String, T.untyped], default: T.unsafe(nil)
  prop :log_level, ::Kirei::Logging::Level, default: T.unsafe(nil)
  prop :metric_default_tags, T::Hash[::String, T.untyped], default: T.unsafe(nil)
  prop :sensitive_keys, T::Array[::Regexp], default: T.unsafe(nil)
  prop :app_name, ::String, default: T.unsafe(nil)
  prop :db_extensions, T::Array[::Symbol], default: T.unsafe(nil)
  prop :db_url, T.nilable(::String)
  prop :db_strict_type_resolving, T.nilable(T::Boolean), default: T.unsafe(nil)

  class << self
    # source://sorbet-runtime/0.5.11287/lib/types/struct.rb#13
    def inherited(s); end
  end
end

# source://kirei//lib/kirei/config.rb#8
Kirei::Config::SENSITIVE_KEYS = T.let(T.unsafe(nil), Array)

# source://kirei//lib/kirei/controller.rb#5
class Kirei::Controller < ::Kirei::Routing::Base
  class << self
    # Statements to be executed after every action.
    #
    # source://kirei//lib/kirei/controller.rb#39
    sig { params(block: T.nilable(T.proc.void)).void }
    def after(&block); end

    # @return [Routing::NilableHooksType]
    #
    # source://kirei//lib/kirei/controller.rb#10
    def after_hooks; end

    # Statements to be executed before every action.
    #
    # In development mode, Rack Reloader might reload this file causing
    # the before hooks to be executed multiple times.
    #
    # source://kirei//lib/kirei/controller.rb#26
    sig { params(block: T.nilable(T.proc.void)).void }
    def before(&block); end

    # source://kirei//lib/kirei/controller.rb#10
    sig { returns(T.nilable(T::Set[T.proc.void])) }
    def before_hooks; end
  end
end

# source://kirei//lib/kirei.rb#0
module Kirei::Errors; end

# https://jsonapi.org/format/#errors
# Error objects MUST be returned as an array keyed by errors in the top level of a JSON:API document.
#
# source://kirei//lib/kirei/errors/json_api_error.rb#10
class Kirei::Errors::JsonApiError < ::T::Struct
  const :code, ::Symbol
  const :detail, T.nilable(::String)
  const :source, T.nilable(::Kirei::Errors::JsonApiErrorSource)

  class << self
    # source://sorbet-runtime/0.5.11287/lib/types/struct.rb#13
    def inherited(s); end
  end
end

# source://kirei//lib/kirei/errors/json_api_error_source.rb#6
class Kirei::Errors::JsonApiErrorSource < ::T::Struct
  const :attribute, T.any(::String, ::Symbol)
  const :model, T.nilable(::String)
  const :id, T.nilable(::String)

  class << self
    # source://sorbet-runtime/0.5.11287/lib/types/struct.rb#13
    def inherited(s); end
  end
end

# source://kirei//lib/kirei.rb#44
Kirei::GEM_ROOT = T.let(T.unsafe(nil), String)

# source://kirei//lib/kirei/helpers.rb#5
module Kirei::Helpers
  class << self
    # Simplified version from Rails' ActiveSupport
    #
    # source://kirei//lib/kirei/helpers.rb#22
    sig { params(string: T.any(::String, ::Symbol)).returns(T::Boolean) }
    def blank?(string); end

    # source://kirei//lib/kirei/helpers.rb#27
    sig { params(object: T.untyped).returns(T.untyped) }
    def deep_stringify_keys(object); end

    # source://kirei//lib/kirei/helpers.rb#32
    sig { params(object: T.untyped).returns(T.untyped) }
    def deep_stringify_keys!(object); end

    # source://kirei//lib/kirei/helpers.rb#37
    sig { params(object: T.untyped).returns(T.untyped) }
    def deep_symbolize_keys(object); end

    # source://kirei//lib/kirei/helpers.rb#42
    sig { params(object: T.untyped).returns(T.untyped) }
    def deep_symbolize_keys!(object); end

    # Simplified version from Rails' ActiveSupport::Inflector#underscore
    #
    # source://kirei//lib/kirei/helpers.rb#11
    sig { params(string: ::String).returns(::String) }
    def underscore(string); end

    private

    # source://kirei//lib/kirei/helpers.rb#53
    sig { params(object: T.untyped, block: ::Proc).returns(T.untyped) }
    def deep_transform_keys(object, &block); end

    # source://kirei//lib/kirei/helpers.rb#72
    sig { params(object: T.untyped, block: ::Proc).returns(T.untyped) }
    def deep_transform_keys!(object, &block); end
  end
end

# Example Usage:
#
#    Kirei::Logging::Logger.call(
#      level: Kirei::Logging::Level::INFO,
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
# By default, "meta" is flattened, and sensitive values are masked using sane defaults that you
# can finetune via `Kirei::App.config.sensitive_keys`.
#
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
#    * Whenever possible, key names follow OpenTelemetry Semantic Conventions, https://opentelemetry.io/docs/concepts/semantic-conventions/
#
# source://kirei//lib/kirei/config.rb#0
module Kirei::Logging; end

# source://kirei//lib/kirei/logging/level.rb#6
class Kirei::Logging::Level < ::T::Enum
  enums do
    UNKNOWN = new
    FATAL = new
    ERROR = new
    WARN = new
    INFO = new
    DEBUG = new
  end

  # source://kirei//lib/kirei/logging/level.rb#19
  sig { returns(::String) }
  def to_human; end
end

# source://kirei//lib/kirei/logging/logger.rb#38
class Kirei::Logging::Logger
  # source://kirei//lib/kirei/logging/logger.rb#46
  sig { void }
  def initialize; end

  # source://kirei//lib/kirei/logging/logger.rb#97
  sig { params(level: ::Kirei::Logging::Level, label: ::String, meta: T::Hash[::String, T.untyped]).void }
  def call(level:, label:, meta: T.unsafe(nil)); end

  # source://kirei//lib/kirei/logging/logger.rb#112
  sig { returns(::Thread) }
  def start_logging_thread; end

  class << self
    # source://kirei//lib/kirei/logging/logger.rb#79
    sig { params(level: ::Kirei::Logging::Level, label: ::String, meta: T::Hash[::String, T.untyped]).void }
    def call(level:, label:, meta: T.unsafe(nil)); end

    # source://kirei//lib/kirei/logging/logger.rb#153
    sig do
      params(
        hash: T::Hash[T.any(::String, ::Symbol), T.untyped],
        prefix: ::String
      ).returns(T::Hash[::String, T.untyped])
    end
    def flatten_hash_and_mask_sensitive_values(hash, prefix = T.unsafe(nil)); end

    # source://kirei//lib/kirei/logging/logger.rb#53
    sig { returns(::Kirei::Logging::Logger) }
    def instance; end

    # source://kirei//lib/kirei/logging/logger.rb#58
    sig { returns(::Logger) }
    def logger; end

    # source://kirei//lib/kirei/logging/logger.rb#142
    sig { params(k: ::String, v: ::String).returns(::String) }
    def mask(k, v); end
  end
end

# source://kirei//lib/kirei/logging/logger.rb#41
Kirei::Logging::Logger::FILTERED = T.let(T.unsafe(nil), String)

# source://kirei//lib/kirei/logging/metric.rb#6
class Kirei::Logging::Metric
  class << self
    # source://kirei//lib/kirei/logging/metric.rb#16
    sig { params(metric_name: ::String, value: ::Integer, tags: T::Hash[::String, T.untyped]).void }
    def call(metric_name, value = T.unsafe(nil), tags: T.unsafe(nil)); end

    # source://kirei//lib/kirei/logging/metric.rb#27
    sig { params(tags: T::Hash[::String, T.untyped]).returns(T::Hash[::String, T.untyped]) }
    def inject_defaults(tags); end
  end
end

# source://kirei//lib/kirei/model.rb#5
module Kirei::Model
  mixes_in_class_methods ::Kirei::Model::ClassMethods

  # source://kirei//lib/kirei/model.rb#10
  sig { returns(::Kirei::Model::BaseClassInterface) }
  def class; end

  # Delete keeps the original object intact. Returns true if the record was deleted.
  # Calling delete multiple times will return false after the first (successful) call.
  #
  # source://kirei//lib/kirei/model.rb#28
  sig { returns(T::Boolean) }
  def delete; end

  # warning: this is not concurrency-safe
  # save keeps the original object intact, and returns a new object with the updated values.
  #
  # source://kirei//lib/kirei/model.rb#36
  sig { returns(T.self_type) }
  def save; end

  # An update keeps the original object intact, and returns a new object with the updated values.
  #
  # source://kirei//lib/kirei/model.rb#18
  sig { params(hash: T::Hash[::Symbol, T.untyped]).returns(T.self_type) }
  def update(hash); end
end

# @abstract Subclasses must implement the `abstract` methods below.
#
# source://kirei//lib/kirei/model.rb#50
module Kirei::Model::BaseClassInterface
  interface!

  # @abstract
  #
  # source://kirei//lib/kirei/model.rb#64
  sig { abstract.returns(T.untyped) }
  def all; end

  # @abstract
  #
  # source://kirei//lib/kirei/model.rb#68
  sig { abstract.params(hash: T.untyped).returns(T.untyped) }
  def create(hash); end

  # @abstract
  #
  # source://kirei//lib/kirei/model.rb#88
  sig { abstract.returns(T.untyped) }
  def db; end

  # @abstract
  #
  # source://kirei//lib/kirei/model.rb#56
  sig { abstract.params(hash: T.untyped).returns(T.untyped) }
  def find_by(hash); end

  # @abstract
  #
  # source://kirei//lib/kirei/model.rb#76
  sig { abstract.params(hash: T.untyped).returns(T.untyped) }
  def resolve(hash); end

  # @abstract
  #
  # source://kirei//lib/kirei/model.rb#80
  sig { abstract.params(hash: T.untyped).returns(T.untyped) }
  def resolve_first(hash); end

  # @abstract
  #
  # source://kirei//lib/kirei/model.rb#84
  sig { abstract.returns(T.untyped) }
  def table_name; end

  # @abstract
  #
  # source://kirei//lib/kirei/model.rb#60
  sig { abstract.params(hash: T.untyped).returns(T.untyped) }
  def where(hash); end

  # @abstract
  #
  # source://kirei//lib/kirei/model.rb#72
  sig { abstract.params(attributes: T.untyped).void }
  def wrap_jsonb_non_primivitives!(attributes); end
end

# source://kirei//lib/kirei/model.rb#92
module Kirei::Model::ClassMethods
  extend T::Generic
  include ::Kirei::Model::BaseClassInterface

  has_attached_class!

  # source://kirei//lib/kirei/model.rb#131
  sig { override.returns(T::Array[T.attached_class]) }
  def all; end

  # default values defined in the model are used, if omitted in the hash
  #
  # source://kirei//lib/kirei/model.rb#142
  sig { override.params(hash: T::Hash[::Symbol, T.untyped]).returns(T.attached_class) }
  def create(hash); end

  # source://kirei//lib/kirei/model.rb#117
  sig { override.returns(::Sequel::Dataset) }
  def db; end

  # source://kirei//lib/kirei/model.rb#183
  sig { override.params(hash: T::Hash[::Symbol, T.untyped]).returns(T.nilable(T.attached_class)) }
  def find_by(hash); end

  # Extra or unknown properties present in the Hash do not raise exceptions at
  # runtime unless the optional strict argument to from_hash is passed
  #
  # Source: https://sorbet.org/docs/tstruct#from_hash-gotchas
  # "strict" defaults to "false".
  #
  # source://kirei//lib/kirei/model.rb#198
  sig do
    override
      .params(
        query: T.any(::Sequel::Dataset, T::Array[T::Hash[::Symbol, T.untyped]]),
        strict: T.nilable(T::Boolean)
      ).returns(T::Array[T.attached_class])
  end
  def resolve(query, strict = T.unsafe(nil)); end

  # source://kirei//lib/kirei/model.rb#214
  sig { override.params(query: ::Sequel::Dataset, strict: T.nilable(T::Boolean)).returns(T.nilable(T.attached_class)) }
  def resolve_first(query, strict = T.unsafe(nil)); end

  # defaults to a pluralized, underscored version of the class name
  #
  # source://kirei//lib/kirei/model.rb#106
  sig { override.returns(::String) }
  def table_name; end

  # source://kirei//lib/kirei/model.rb#126
  sig { override.params(hash: T::Hash[::Symbol, T.untyped]).returns(T::Array[T.attached_class]) }
  def where(hash); end

  # source://kirei//lib/kirei/model.rb#166
  sig { override.params(attributes: T::Hash[T.any(::String, ::Symbol), T.untyped]).void }
  def wrap_jsonb_non_primivitives!(attributes); end
end

# we don't know what Oj does under the hood with the options hash, so don't freeze it
#
# source://kirei//lib/kirei.rb#35
Kirei::OJ_OPTIONS = T.let(T.unsafe(nil), Hash)

# source://kirei//lib/kirei/app.rb#0
module Kirei::Routing; end

# source://kirei//lib/kirei/routing/base.rb#8
class Kirei::Routing::Base
  # source://kirei//lib/kirei/routing/base.rb#12
  sig { params(params: T::Hash[::String, T.untyped]).void }
  def initialize(params: T.unsafe(nil)); end

  # source://kirei//lib/kirei/routing/base.rb#24
  sig do
    params(
      env: T::Hash[::String, T.any(::IO, ::Numeric, ::Puma::Client, ::Puma::Configuration, ::String, ::StringIO, ::TCPSocket, T::Array[T.untyped], T::Boolean)]
    ).returns([::Integer, T::Hash[::String, ::String], T.any(::Proc, T::Array[::String])])
  end
  def call(env); end

  # source://kirei//lib/kirei/routing/base.rb#136
  sig { returns(T::Hash[::String, ::String]) }
  def default_headers; end

  # source://kirei//lib/kirei/routing/base.rb#18
  sig { returns(T::Hash[::String, T.untyped]) }
  def params; end

  # * "status": defaults to 200
  # * "headers": Kirei adds some default headers for security, but the user can override them
  #
  # source://kirei//lib/kirei/routing/base.rb#127
  sig do
    params(
      body: ::String,
      status: ::Integer,
      headers: T::Hash[::String, ::String]
    ).returns([::Integer, T::Hash[::String, ::String], T.any(::Proc, T::Array[::String])])
  end
  def render(body, status: T.unsafe(nil), headers: T.unsafe(nil)); end

  private

  # source://kirei//lib/kirei/routing/base.rb#166
  sig do
    params(
      controller: T.class_of(Kirei::Controller),
      hooks_type: ::Symbol
    ).returns(T.nilable(T::Set[T.proc.void]))
  end
  def collect_hooks(controller, hooks_type); end

  # source://kirei//lib/kirei/routing/base.rb#21
  sig { returns(::Kirei::Routing::Router) }
  def router; end

  # source://kirei//lib/kirei/routing/base.rb#154
  sig { params(hooks: T.nilable(T::Set[T.proc.void])).void }
  def run_hooks(hooks); end
end

# source://kirei//lib/kirei/routing/nilable_hooks_type.rb#6
Kirei::Routing::NilableHooksType = T.type_alias { T.nilable(T::Set[T.proc.void]) }

# source://kirei//lib/kirei/routing/rack_env_type.rb#6
Kirei::Routing::RackEnvType = T.type_alias { T::Hash[::String, T.any(::IO, ::Numeric, ::Puma::Client, ::Puma::Configuration, ::String, ::StringIO, ::TCPSocket, T::Array[T.untyped], T::Boolean)] }

# https://github.com/rack/rack/blob/main/UPGRADE-GUIDE.md#rack-3-upgrade-guide
#
# source://kirei//lib/kirei/routing/rack_response_type.rb#7
Kirei::Routing::RackResponseType = T.type_alias { [::Integer, T::Hash[::String, ::String], T.any(::Proc, T::Array[::String])] }

# source://kirei//lib/kirei/routing/route.rb#6
class Kirei::Routing::Route < ::T::Struct
  const :verb, ::Kirei::Routing::Verb
  const :path, ::String
  const :controller, T.class_of(Kirei::Controller)
  const :action, ::String

  class << self
    # source://sorbet-runtime/0.5.11287/lib/types/struct.rb#13
    def inherited(s); end
  end
end

# Usage:
#
# Router.add_routes([
#   Route.new(
#     verb: Verb::GET,
#     path: "/livez",
#     controller: Controllers::HealthController,
#     action: "livez",
#   ),
# ])
#
# source://kirei//lib/kirei/routing/router.rb#20
class Kirei::Routing::Router
  include ::Singleton
  extend ::Singleton::SingletonClassMethods

  # source://kirei//lib/kirei/routing/router.rb#29
  sig { void }
  def initialize; end

  # source://kirei//lib/kirei/routing/router.rb#42
  sig { params(verb: ::Kirei::Routing::Verb, path: ::String).returns(T.nilable(::Kirei::Routing::Route)) }
  def get(verb, path); end

  # source://kirei//lib/kirei/routing/router.rb#34
  sig { returns(T::Hash[::String, ::Kirei::Routing::Route]) }
  def routes; end

  class << self
    # source://kirei//lib/kirei/routing/router.rb#48
    sig { params(routes: T::Array[::Kirei::Routing::Route]).void }
    def add_routes(routes); end

    private

    def allocate; end
    def new(*_arg0); end
  end
end

# source://kirei//lib/kirei/routing/router.rb#24
Kirei::Routing::Router::RoutesHash = T.type_alias { T::Hash[::String, ::Kirei::Routing::Route] }

# source://kirei//lib/kirei/routing/verb.rb#6
class Kirei::Routing::Verb < ::T::Enum
  enums do
    GET = new
    POST = new
    PUT = new
    PATCH = new
    DELETE = new
    HEAD = new
    OPTIONS = new
    TRACE = new
    CONNECT = new
  end
end

# source://kirei//lib/kirei.rb#0
module Kirei::Services; end

# source://kirei//lib/kirei/services/result.rb#6
class Kirei::Services::Result
  extend T::Generic

  ErrorType = type_member { { fixed: T::Array[::Kirei::Errors::JsonApiError] } }
  ResultType = type_member { { upper: Object } }

  # source://kirei//lib/kirei/services/result.rb#19
  sig { params(result: T.nilable(ResultType), errors: ErrorType).void }
  def initialize(result: T.unsafe(nil), errors: T.unsafe(nil)); end

  # source://kirei//lib/kirei/services/result.rb#46
  sig { returns(ErrorType) }
  def errors; end

  # source://kirei//lib/kirei/services/result.rb#34
  sig { returns(T::Boolean) }
  def failed?; end

  # source://kirei//lib/kirei/services/result.rb#39
  sig { returns(ResultType) }
  def result; end

  # source://kirei//lib/kirei/services/result.rb#29
  sig { returns(T::Boolean) }
  def success?; end
end

# source://kirei//lib/kirei/services/runner.rb#6
class Kirei::Services::Runner
  class << self
    # source://kirei//lib/kirei/services/runner.rb#18
    sig do
      type_parameters(:T)
        .params(
          class_name: ::String,
          log_tags: T::Hash[::String, T.untyped],
          _: T.proc.returns(T.type_parameter(:T))
        ).returns(T.type_parameter(:T))
    end
    def call(class_name, log_tags: T.unsafe(nil), &_); end
  end
end

# source://kirei//lib/kirei/version.rb#5
Kirei::VERSION = T.let(T.unsafe(nil), String)
