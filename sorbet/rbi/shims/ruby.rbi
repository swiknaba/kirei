# typed: true

#
# The RubyVM module only exists on MRI. RubyVM is not defined in other Ruby implementations such as JRuby and TruffleRuby.
#
# The RubyVM module provides some access to MRI internals. This module is for very limited purposes, such as debugging, prototyping, and research. Normal users must not use it. This module is not portable between Ruby implementations.
#
class RubyVM
  module YJIT
    extend T::Sig

    sig { returns(T::Boolean) }
    def self.enabled?; end
  end
end
