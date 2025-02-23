module UIng
  class MenuItem
    include MethodMissing

    def initialize(@ref_ptr : Pointer(LibUI::MenuItem))
    end

    # no new_menu_item function in libui

    def on_clicked(&block : UIng::Window -> Void)
      UIng.menu_item_on_clicked(@ref_ptr, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
