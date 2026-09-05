require "./control"

module UIng
  class Group < Control
    block_constructor

    @child_ref : Control?

    def initialize(title : String, margined : Bool = false)
      @ref_ptr = LibUI.new_group(title)
      self.margined = true if margined
      register_control
    end

    protected def after_destroy : Nil
      @child_ref = nil
    end

    def delete(child : Control)
      unless @child_ref.same?(child)
        raise "Group does not contain child"
      end
      self.child = nil
    end

    def title : String?
      str_ptr = LibUI.group_title(ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def title=(title : String) : Nil
      LibUI.group_set_title(ref_ptr, title)
    end

    def child=(control : Control) : Nil
      check_available
      control.check_can_move(self)
      previous_child = @child_ref
      # uiGroupSetChild detaches the existing child; it does not destroy it.
      # Update the Crystal ownership graph only after the native operation
      # succeeds, so an exception cannot leave the two trees inconsistent.
      set_native_child(UIng.to_control(control))
      previous_child.try &.release_ownership
      @child_ref = control
      control.take_ownership(self)
    end

    def child=(control : Nil) : Nil
      check_available
      set_native_child(Pointer(LibUI::Control).null)
      @child_ref.try &.release_ownership
      @child_ref = nil
    end

    def child : Control?
      @child_ref
    end

    protected def set_native_child(child : Pointer(LibUI::Control)) : Nil
      LibUI.group_set_child(ref_ptr, child)
    end

    # alias for `child=`
    def set_child(control) : Nil
      self.child = control
    end

    # For DSL style
    def set_child(&block : -> Control)
      control = block.call
      self.child = control
    end

    def margined? : Bool
      LibUI.group_margined(ref_ptr) != 0
    end

    def margined=(margined : Bool) : Nil
      LibUI.group_set_margined(ref_ptr, margined ? 1 : 0)
    end

    def to_unsafe
      ref_ptr
    end
  end
end
