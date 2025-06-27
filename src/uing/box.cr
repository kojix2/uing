require "./control"

module UIng
  # Note: The name Box is already taken by Crystal's built-in class Box.

  # Why not use HorizontalBox and VerticalBox?
  # For consistency with the libui C API naming convention,
  # we use a single Box class with orientation parameter.
  # This matches the libui functions like `uiBoxAppend`, `uiBoxSetPadded`, etc.

  class Box < Control
    block_constructor

    @ref_ptr : Pointer(LibUI::Box)
    @children_refs : Array(Control) = [] of Control

    def initialize(orientation : Symbol, padded : Bool = false)
      case orientation
      when :horizontal
        @ref_ptr = LibUI.new_horizontal_box
      when :vertical
        @ref_ptr = LibUI.new_vertical_box
      else
        raise "Invalid orientation: #{orientation}"
      end
      self.padded = true if padded
    end

    def destroy
      @children_refs.clear
      super
    end

    def delete(child : Control)
      if index = @children_refs.index(child)
        delete(index)
      end
    end

    def append(control, stretchy : Bool = false) : Nil
      control.check_can_move
      LibUI.box_append(@ref_ptr, UIng.to_control(control), stretchy)
      @children_refs << control
      control.take_ownership(self)
    end

    # For DSL style
    def append(stretchy : Bool = false, &block : -> Control) : Nil
      control = block.call
      append(control)
    end

    def num_children : Int32
      LibUI.box_num_children(@ref_ptr)
    end

    def delete(index : Int32) : Nil
      child = @children_refs[index]
      LibUI.box_delete(@ref_ptr, index)
      @children_refs.delete_at(index)
      child.release_ownership
    end

    def padded? : Bool
      LibUI.box_padded(@ref_ptr)
    end

    def padded=(padded : Bool) : Nil
      LibUI.box_set_padded(@ref_ptr, padded)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
