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

    # Flag to track if the control is released (prevents double-free)
    @released : Bool = false

    # Parent reference (for GC protection and tree uniqueness)
    # Use `__parent__` and `__set_parent__` if you need to access native functions for some reason
    protected getter parent : Control?

    # Public getter for parent (for testing and debugging)
    def parent : Control?
      @parent
    end

    # Helper method to check if this control can be moved to a new parent
    # Raises an exception if the control already has a parent (following libui-ng behavior)
    protected def check_can_move : Nil
      check_available
      if @parent
        raise "You cannot give a uiControl a parent while it already has one"
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
      raise "#{self.class} has already been destroyed" if @released
    end

    protected def check_can_destroy : Nil
      check_available
      if @parent
        raise "You cannot destroy a child control directly; remove it from its parent first"
      end
    end

    protected def before_destroy : Nil
    end

    # libui-ng container destructors call uiControlDestroy() on their children.
    # The child Crystal wrapper does not see Control#destroy in that path, so
    # containers call this before destroying their own native control.
    protected def mark_released_from_parent_destroy : Nil
      return if @released
      before_destroy
      @parent = nil
      @released = true
    end

    # Some native callbacks destroy a root control inside libui-ng itself. The
    # close-window callback is the important example: returning true from
    # uiWindowOnClosing triggers uiControlDestroy(uiControl(window)) in C.
    protected def mark_released_from_native_destroy : Nil
      return if @released
      before_destroy
      @parent = nil
      @released = true
    end

    def released? : Bool
      @released
    end

    def destroy : Nil
      return if @released
      # libui-ng rejects uiFreeControl() while the control still has a parent.
      # Ask callers to detach with the container's delete/remove API instead.
      check_can_destroy
      before_destroy
      LibUI.control_destroy(UIng.to_control(@ref_ptr))
      @released = true
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
      LibUI.control_toplevel(UIng.to_control(@ref_ptr))
    end

    def visible? : Bool
      check_available
      LibUI.control_visible(UIng.to_control(@ref_ptr))
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
      LibUI.control_enabled(UIng.to_control(@ref_ptr))
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
      LibUI.control_enabled_to_user(UIng.to_control(@ref_ptr))
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
      @released = true
    end
  end
end
