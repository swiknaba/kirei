# typed: true

class Fiber
  #
  # the Sorbet stdlib has no types for this,
  # thus Sorbet fallsback to assume "Ractor.new" is from "Object.new"
  # which does not allow any further arguments and is private.
  #
  sig { params(blocking: T::Boolean, blk: T.proc.params(arg: T.untyped).returns(T.untyped)).void }
  def initialize(blocking: false, &blk); end

  # Sets Fiber scheduler for the current thread. If the scheduler is set, non-blocking fibers (created by ::new with blocking: false, or by ::schedule) call that scheduler's hook methods on potentially blocking operations, and the current thread will call scheduler's close method on finalization (allowing the scheduler to properly manage all non-finished fibers).
  #
  # scheduler can be an object of any class corresponding to Fiber::SchedulerInterface. Its implementation is up to the user.
  #
  # See also the "Non-blocking fibers" section in class docs.
  sig { params(scheduler: T.untyped).returns(T.untyped) }
  def self.set_scheduler(scheduler); end
end
