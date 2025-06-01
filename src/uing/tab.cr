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

    def append(name : String, control, margined : Bool = false)
      UIng.tab_append(@ref_ptr, name, control)
      index = num_pages - 1
      set_margined(index, margined) if margined
    end

    def insert_at(name : String, index : Int32, control, margined : Bool = false)
      UIng.tab_insert_at(@ref_ptr, name, index, control)
      set_margined(index, margined) if margined
    end

    def on_selected(&block : Int32 -> Void)
      wrapper = -> {
        idx = UIng.tab_selected(@ref_ptr)
        block.call(idx)
      }
      @on_selected_box = ::Box.box(wrapper)
      UIng.tab_on_selected(@ref_ptr, @on_selected_box.not_nil!, &wrapper)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
