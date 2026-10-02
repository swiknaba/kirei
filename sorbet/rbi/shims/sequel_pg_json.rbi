# typed: strict

# The pg_json database extension adds this setter at runtime via
# `Sequel::Database#extension(:pg_json)`; Tapioca cannot see it.
#
# Source: https://github.com/jeremyevans/sequel/blob/5.75.0/lib/sequel/extensions/pg_json.rb#L8
class Sequel::Database
  sig { params(value: T::Boolean).returns(T::Boolean) }
  def wrap_json_primitives=(value); end
end
