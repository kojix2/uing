require "../spec_helper"

module SpecSupport
  # Give a fresh control a native owner, then destroy the complete tree even
  # when an assertion fails. Runtime initialization belongs to the caller.
  def self.with_native_control(control : T, &) forall T
    window = UIng::Window.new("Native control spec", 320, 200)
    window.child = control
    yield control
  ensure
    window.try &.destroy
  end
end
