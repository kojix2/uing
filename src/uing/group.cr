require "./control"

module UIng
  class Group < Control
    block_constructor

    @child_ref : Control?

    def initialize(title : String, margined : Bool = false)
      @ref_ptr = LibUI.new_group(title)
      self.margined = true if margined
    end

    def destroy
      @child_ref = nil
      super
    end

    # Raises: Not supported for this container.
    def delete(child : Control)
      raise "Group does not support delete(child : Control)"
    end

    def title : String?
      str_ptr = LibUI.group_title(@ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def title=(title : String) : Nil
      LibUI.group_set_title(@ref_ptr, title)
    end

    def child=(control) : Nil
      control.check_can_move
      # libui-ng automatically replaces existing child, but we need to
      # release ownership on Crystal side to maintain reference consistency
      if child_ref = @child_ref
        child_ref.release_ownership
      end
      LibUI.group_set_child(@ref_ptr, UIng.to_control(control))
      @child_ref = control
      control.take_ownership(self)
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
      LibUI.group_margined(@ref_ptr)
    end

    def margined=(margined : Bool) : Nil
      LibUI.group_set_margined(@ref_ptr, margined)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
