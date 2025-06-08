require "./control"

module UIng
  class Form < Control
    block_constructor

    @children_refs : Array(Control) = [] of Control

    def initialize(@ref_ptr : Pointer(LibUI::Form))
    end

    def initialize(padded : Bool = false)
      @ref_ptr = LibUI.new_form
      self.padded = true if padded
    end

    def append(label : String, control, stretchy : Bool = false) : Nil
      control.check_can_move
      LibUI.form_append(@ref_ptr, label, UIng.to_control(control), stretchy)
      @children_refs << control
      control.take_ownership(self)
    end

    def num_children : Int32
      LibUI.form_num_children(@ref_ptr)
    end

    def delete(index : Int32) : Nil
      child = @children_refs[index]
      LibUI.form_delete(@ref_ptr, index)
      @children_refs.delete_at(index)
      child.release_ownership
    end

    def padded? : Bool
      LibUI.form_padded(@ref_ptr)
    end

    def padded=(padded : Bool) : Nil
      LibUI.form_set_padded(@ref_ptr, padded)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
