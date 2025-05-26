module UIng
  class MenuItem
    include MethodMissing

    # Store callback box to prevent GC collection
    @on_clicked_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::MenuItem))
    end

    # no new_menu_item function in libui

    def on_clicked(&block : UIng::Window -> Void)
      # Convert to the internal callback format that matches UIng.cr expectation
      callback2 = ->(w : Pointer(LibUI::Window)) {
        block.call(UIng::Window.new(w))
      }
      @on_clicked_box = ::Box.box(callback2)
      UIng.menu_item_on_clicked(@ref_ptr, @on_clicked_box.not_nil!, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
