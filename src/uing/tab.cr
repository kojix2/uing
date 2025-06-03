require "./control"

module UIng
  class Tab
    include Control; block_constructor

    # Store callback box to prevent GC collection
    @on_selected_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::Tab))
    end

    def initialize
      @ref_ptr = LibUI.new_tab
    end

    def append(name : String, control, margined : Bool = false) : Nil
      LibUI.tab_append(@ref_ptr, name, UIng.to_control(control))
      index = num_pages - 1
      set_margined(index, margined) if margined
    end

    def insert_at(name : String, index : Int32, control, margined : Bool = false) : Nil
      LibUI.tab_insert_at(@ref_ptr, name, index, UIng.to_control(control))
      set_margined(index, margined) if margined
    end

    def delete(index : Int32) : Nil
      LibUI.tab_delete(@ref_ptr, index)
    end

    def num_pages : Int32
      LibUI.tab_num_pages(@ref_ptr)
    end

    def margined?(index : Int32) : Bool
      LibUI.tab_margined(@ref_ptr, index)
    end

    def set_margined(index : Int32, margined : Bool) : Nil
      LibUI.tab_set_margined(@ref_ptr, index, margined)
    end

    def selected : Int32
      LibUI.tab_selected(@ref_ptr)
    end

    def selected=(index : Int32) : Nil
      LibUI.tab_set_selected(@ref_ptr, index)
    end

    def on_selected(&block : Int32 -> Void)
      wrapper = -> {
        idx = self.selected
        block.call(idx)
      }
      @on_selected_box = ::Box.box(wrapper)
      LibUI.tab_on_selected(@ref_ptr, ->(sender, data) do
        data_as_callback = ::Box(typeof(wrapper)).unbox(data)
        data_as_callback.call
      end, @on_selected_box.not_nil!)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
