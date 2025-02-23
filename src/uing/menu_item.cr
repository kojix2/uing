module UIng
  class MenuItem
    include MethodMissing

    def initialize(@ref_ptr : Pointer(LibUI::MenuItem))
    end

    # no new_menu_item function in libui

    def to_unsafe
      @ref_ptr
    end
  end
end
