require "./control"

module UIng
  class Form < Control
    block_constructor

    @children_refs : Array(Control) = [] of Control

    def initialize(padded : Bool = false)
      @ref_ptr = LibUI.new_form
      self.padded = true if padded
    end

    protected def before_destroy : Nil
      @children_refs.each do |child|
        child.mark_released_from_parent_destroy
      end
      @children_refs.clear
    end

    def delete(child : Control)
      if index = @children_refs.index(child)
        delete(index)
      else
        raise "Form does not contain child"
      end
    end

    def append(label : String, control, stretchy : Bool = false) : Nil
      control.check_can_move
      LibUI.form_append(ref_ptr, label, UIng.to_control(control), stretchy)
      @children_refs << control
      control.take_ownership(self)
    end

    # For DSL style
    def append(label : String, stretchy : Bool = false, &block : -> Control) : Nil
      control = block.call
      append(label, control, stretchy)
    end

    def num_children : Int32
      LibUI.form_num_children(ref_ptr)
    end

    def delete(index : Int32) : Nil
      child = @children_refs[index]
      LibUI.form_delete(ref_ptr, index)
      @children_refs.delete_at(index)
      child.release_ownership
    end

    def padded? : Bool
      LibUI.form_padded(ref_ptr)
    end

    def padded=(padded : Bool) : Nil
      LibUI.form_set_padded(ref_ptr, padded)
    end

    def to_unsafe
      ref_ptr
    end
  end
end
