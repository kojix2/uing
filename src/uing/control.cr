require "./block_constructor"

module UIng
  abstract class Control
    include BlockConstructor

    # Flag to track if the control is released (prevents double-free)
    @released : Bool = false

    # Parent reference (for GC protection and tree uniqueness)
    # Use `__parent__` and `__set_parent__` if you need to access native functions for some reason
    protected property parent : Control?

    # Public getter for parent (for testing and debugging)
    def parent : Control?
      @parent
    end

    # Helper method to check if this control can be moved to a new parent
    # Raises an exception if the control already has a parent (following libui-ng behavior)
    protected def check_can_move : Nil
      if @parent
        raise "You cannot give a uiControl a parent while it already has one"
      end
    end

    # Helper method to take ownership of this control by a new parent
    # Should only be called after check_can_move
    protected def take_ownership(new_parent : Control) : Nil
      @parent = new_parent
    end

    # Helper method to release ownership of this control (remove parent reference)
    protected def release_ownership : Nil
      @parent = nil
    end

    def destroy : Nil
      return if @released
      # Child controls should generally not be destroyed directly.
      # When destroying a control, its parent-child relationship should be properly terminated.
      @parent.try(&.delete(self))
      LibUI.control_destroy(UIng.to_control(@ref_ptr))
      @released = true
    end

    def handle
      LibUI.control_handle(UIng.to_control(@ref_ptr))
    end

    # native libui function
    def __parent__
      LibUI.control_parent(UIng.to_control(@ref_ptr))
    end

    # native libui function
    # should not be used directly
    def __set_parent__(parent) : Nil
      LibUI.control_set_parent(UIng.to_control(@ref_ptr), UIng.to_control(parent))
    end

    def toplevel? : Bool
      LibUI.control_toplevel(UIng.to_control(@ref_ptr))
    end

    def visible? : Bool
      LibUI.control_visible(UIng.to_control(@ref_ptr))
    end

    def show : Nil
      LibUI.control_show(UIng.to_control(@ref_ptr))
    end

    def hide : Nil
      LibUI.control_hide(UIng.to_control(@ref_ptr))
    end

    def enabled? : Bool
      LibUI.control_enabled(UIng.to_control(@ref_ptr))
    end

    def enable : Nil
      LibUI.control_enable(UIng.to_control(@ref_ptr))
    end

    def disable : Nil
      LibUI.control_disable(UIng.to_control(@ref_ptr))
    end

    def enabled_to_user? : Bool
      LibUI.control_enabled_to_user(UIng.to_control(@ref_ptr))
    end

    def verify_set_parent(parent) : Nil
      LibUI.control_verify_set_parent(UIng.to_control(@ref_ptr), UIng.to_control(parent))
    end

    def delete(child : Control)
      raise "delete(child : Control) is not implemented for #{self.class}"
    end

    abstract def to_unsafe
  end
end
