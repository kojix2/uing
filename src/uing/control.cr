require "./block_constructor"

module UIng
  abstract class Control
    include BlockConstructor

    macro inherited
      # All native calls in Control subclasses should go through this accessor.
      # Parent destruction can free the underlying uiControl behind a still-live
      # Crystal wrapper, so touching @ref_ptr directly after construction risks
      # a use-after-free.
      protected def ref_ptr
        check_available
        @ref_ptr
      end
    end

    private enum State
      Alive
      DestroyPending
      Destroyed
    end

    @state : State = State::Alive

    # Parent reference (for GC protection and tree uniqueness)
    # Use `__parent__` and `__set_parent__` if you need to access native functions for some reason
    protected getter parent : Control?

    # Public getter for parent (for testing and debugging)
    def parent : Control?
      @parent
    end

    # Helper method to check if this control can be moved to a new parent.
    # Raises before a native call if the move would violate the control tree.
    protected def check_can_move(new_parent : Control) : Nil
      check_available
      new_parent.check_available

      raise "A top-level control cannot have a parent" if is_a?(Window)

      if @parent
        raise "You cannot give a uiControl a parent while it already has one"
      end

      ancestor : Control? = new_parent
      while ancestor
        raise "A control cannot be added to itself or one of its descendants" if same?(ancestor)
        ancestor = ancestor.parent
      end
    end

    # Helper method to take ownership of this control by a new parent
    # Should only be called after check_can_move
    protected def take_ownership(new_parent : Control) : Nil
      check_available
      @parent = new_parent
    end

    # Helper method to release ownership of this control (remove parent reference)
    protected def release_ownership : Nil
      @parent = nil
    end

    protected def check_available : Nil
      raise "#{self.class} has already been destroyed" unless @state.alive?
    end

    protected def check_can_destroy : Nil
      check_available
      if @parent
        raise "You cannot destroy a child control directly; remove it from its parent first"
      end
    end

    protected def after_destroy : Nil
    end

    protected def mark_destroyed_from_native : Nil
      return if @state.destroyed?
      @state = State::Destroyed
      @parent = nil
      after_destroy
    end

    protected def register_control(install_destroy_callback : Bool = true) : Nil
      ControlRegistry.register(self, @ref_ptr.as(Pointer(LibUI::Control)), install_destroy_callback)
    end

    protected def lifecycle_state : State
      @state
    end

    protected def mark_destroy_pending : Bool
      return false unless @state.alive?
      @state = State::DestroyPending
      true
    end

    protected def destroy_native : Nil
      LibUI.control_destroy(UIng.to_control(@ref_ptr))
    end

    def released? : Bool
      !@state.alive?
    end

    def destroy : Nil
      return unless @state.alive?
      # libui-ng rejects uiFreeControl() while the control still has a parent.
      # Ask callers to detach with the container's delete/remove API instead.
      check_can_destroy
      return unless mark_destroy_pending
      destroy_native
    end

    def detach : self
      check_available
      @parent.try &.delete(self)
      self
    end

    def handle
      check_available
      LibUI.control_handle(UIng.to_control(@ref_ptr))
    end

    # native libui function
    def __parent__
      check_available
      LibUI.control_parent(UIng.to_control(@ref_ptr))
    end

    # native libui function
    # should not be used directly
    def __set_parent__(parent) : Nil
      check_available
      LibUI.control_set_parent(UIng.to_control(@ref_ptr), UIng.to_control(parent))
    end

    def toplevel? : Bool
      check_available
      LibUI.control_toplevel(UIng.to_control(@ref_ptr)) != 0
    end

    def visible? : Bool
      check_available
      LibUI.control_visible(UIng.to_control(@ref_ptr)) != 0
    end

    def show : Nil
      check_available
      LibUI.control_show(UIng.to_control(@ref_ptr))
    end

    def hide : Nil
      check_available
      LibUI.control_hide(UIng.to_control(@ref_ptr))
    end

    def enabled? : Bool
      check_available
      LibUI.control_enabled(UIng.to_control(@ref_ptr)) != 0
    end

    def enable : Nil
      check_available
      LibUI.control_enable(UIng.to_control(@ref_ptr))
    end

    def disable : Nil
      check_available
      LibUI.control_disable(UIng.to_control(@ref_ptr))
    end

    def enabled_to_user? : Bool
      check_available
      LibUI.control_enabled_to_user(UIng.to_control(@ref_ptr)) != 0
    end

    def verify_set_parent(parent) : Nil
      check_available
      LibUI.control_verify_set_parent(UIng.to_control(@ref_ptr), UIng.to_control(parent))
    end

    def delete(child : Control)
      raise "delete(child : Control) is not implemented for #{self.class}"
    end

    abstract def to_unsafe

    def finalize
      @state = State::Destroyed
    end
  end
end
