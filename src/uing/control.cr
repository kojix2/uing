require "./block_constructor"

module UIng
  abstract class Control
    include BlockConstructor

    protected abstract def raw_control_ptr : Pointer(UIng::LibUI::Control)

    macro inherited
      # destroy_native runs after the wrapper becomes unavailable, so it cannot
      # use ref_ptr or to_unsafe. Keep this unchecked pointer internal.
      protected def raw_control_ptr : Pointer(UIng::LibUI::Control)
        @ref_ptr.as(Pointer(UIng::LibUI::Control))
      end

      # Normal native calls in Control subclasses should go through this accessor.
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

    # A Control created by a block constructor must not remain registered when
    # configuration of that instance fails. Detach first because libui-ng does
    # not allow an attached child control to be destroyed directly.
    protected def __block_constructor_failed__ : Nil
      return if released?
      detach
      destroy
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
      LibUI.control_destroy(raw_control_ptr)
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

    def handle : Pointer(Void)
      Pointer(Void).new(LibUI.control_handle(UIng.to_control(self)).to_u64)
    end

    # Sets a descriptive tooltip for this control.
    #
    # Container tooltips apply only to the container's own surface, not to its
    # children. For sliders, this temporarily replaces the value tooltip.
    def tooltip=(tooltip : String) : Nil
      LibUI.control_set_tooltip(UIng.to_control(ref_ptr), tooltip)
    end

    # Removes this control's descriptive tooltip.
    def tooltip=(tooltip : Nil) : Nil
      LibUI.control_set_tooltip(UIng.to_control(ref_ptr), Pointer(LibC::Char).null)
    end

    # native libui function
    private def __parent__
      LibUI.control_parent(UIng.to_control(self))
    end

    # native libui function
    # should not be used directly
    private def __set_parent__(parent) : Nil
      LibUI.control_set_parent(UIng.to_control(self), UIng.to_control(parent))
    end

    def toplevel? : Bool
      LibUI.control_toplevel(UIng.to_control(self)) != 0
    end

    def visible? : Bool
      LibUI.control_visible(UIng.to_control(self)) != 0
    end

    def show : Nil
      LibUI.control_show(UIng.to_control(self))
    end

    def hide : Nil
      LibUI.control_hide(UIng.to_control(self))
    end

    def enabled? : Bool
      LibUI.control_enabled(UIng.to_control(self)) != 0
    end

    def enable : Nil
      LibUI.control_enable(UIng.to_control(self))
    end

    def disable : Nil
      LibUI.control_disable(UIng.to_control(self))
    end

    # Overrides the minimum size this control requests from its parent.
    #
    # Each axis is independent. Pass `-1` to restore its normal minimum-size
    # calculation, `0` to remove the control's own minimum request, or a
    # positive value to replace it. This does not fix the control to this size;
    # its parent may still allocate more space. Top-level controls are not
    # supported.
    def set_minimum_size(width : Int32, height : Int32) : Nil
      if width < -1 || height < -1
        raise ArgumentError.new("minimum width and height must be at least -1")
      end

      control = UIng.to_control(ref_ptr)
      if LibUI.control_toplevel(control) != 0
        raise ArgumentError.new("minimum size cannot be set on a top-level control")
      end

      LibUI.control_set_minimum_size(control, width, height)
    end

    def enabled_to_user? : Bool
      LibUI.control_enabled_to_user(UIng.to_control(self)) != 0
    end

    private def verify_set_parent(parent) : Nil
      LibUI.control_verify_set_parent(UIng.to_control(self), UIng.to_control(parent))
    end

    def delete(child : Control)
      raise "delete(child : Control) is not implemented for #{self.class}"
    end

    abstract def to_unsafe
  end
end
