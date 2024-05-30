# typed: true

class Ractor
  #
  # the Sorbet stdlib types this as "self.initialize",
  # thus Sorbet fallsback to assume "Ractor.new" is from "Object.new"
  # which does not allow any further arguments and is private.
  #
  sig { params(rest: T.untyped, blk: T.proc.params(arg: T.untyped).returns(T.untyped)).void }
  def initialize(**rest, &blk); end

  class ClosedError < StopIteration; end
end
