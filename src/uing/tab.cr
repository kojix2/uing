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
