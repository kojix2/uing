module UIng
  class Menu
    include MethodMissing; block_constructor

    def initialize(@ref_ptr : Pointer(LibUI::Menu))
    end

    def initialize(name : String)
      @ref_ptr = LibUI.new_menu(name)
    end

    def append_check_item(name : String, checked : Bool) : MenuItem
      item = append_check_item(name)
      item.checked = checked
      item
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
