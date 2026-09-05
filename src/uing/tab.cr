require "./control"

module UIng
  class Tab < Control
    block_constructor

    # Store callback box to prevent GC collection
    @on_selected_box : Pointer(Void)?
    @children_refs : Array(Control) = [] of Control

    def initialize
      @ref_ptr = LibUI.new_tab
      register_control
    end

    protected def after_destroy : Nil
      @children_refs.clear
      @on_selected_box = nil
    end

    def append(name : String, control, margined : Bool = false) : Nil
      control.check_can_move
      LibUI.tab_append(ref_ptr, name, UIng.to_control(control))
      @children_refs << control
      control.take_ownership(self)
      index = num_pages - 1
      set_margined(index, margined) if margined
    end

    # For DSL style
    def append(name : String, margined : Bool = false, &block : -> Control) : Nil
      control = block.call
      append(name, control, margined)
    end

    def insert_at(name : String, index : Int32, control, margined : Bool = false) : Nil
      control.check_can_move
      LibUI.tab_insert_at(ref_ptr, name, index, UIng.to_control(control))
      @children_refs.insert(index, control)
      control.take_ownership(self)
      set_margined(index, margined) if margined
    end

    def delete(index : Int32) : Nil
      if index < 0 || index >= @children_refs.size
        raise IndexError.new("Index out of bounds")
      end

      child = @children_refs[index]
      delete_native_child(index)
      @children_refs.delete_at(index)
      child.release_ownership
    end

    protected def delete_native_child(index : Int32) : Nil
      LibUI.tab_delete(ref_ptr, index)
    end

    def delete(child : Control)
      if index = @children_refs.index(child)
        delete(index)
      else
        raise "Tab does not contain child"
      end
    end

    def num_pages : Int32
      LibUI.tab_num_pages(ref_ptr)
    end

    def margined?(index : Int32) : Bool
      LibUI.tab_margined(ref_ptr, index)
    end

    def set_margined(index : Int32, margined : Bool) : Nil
      LibUI.tab_set_margined(ref_ptr, index, margined)
    end

    def selected : Int32
      LibUI.tab_selected(ref_ptr)
    end

    def selected=(index : Int32) : Nil
      LibUI.tab_set_selected(ref_ptr, index)
    end

    def on_selected(&block : Int32 -> Nil) : Nil
      wrapper = -> : Nil {
        idx = selected
        block.call(idx)
      }
      @on_selected_box = ::Box.box(wrapper)
      if boxed_data = @on_selected_box
        LibUI.tab_on_selected(
          ref_ptr,
          ->(_sender, data) : Nil {
            begin
              data_as_callback = ::Box(typeof(wrapper)).unbox(data)
              data_as_callback.call
            rescue e
              UIng.handle_callback_error(e, "Tab on_selected")
            end
          },
          boxed_data
        )
      end
    end

    def to_unsafe
      ref_ptr
    end
  end
end
