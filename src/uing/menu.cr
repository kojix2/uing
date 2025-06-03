module UIng
  class Menu
    include BlockConstructor; block_constructor

    def initialize(@ref_ptr : Pointer(LibUI::Menu))
    end

    def initialize(name : String)
      @ref_ptr = LibUI.new_menu(name)
    end

    def append_item(name : String) : MenuItem
      ref_ptr = LibUI.menu_append_item(@ref_ptr, name)
      MenuItem.new(ref_ptr)
    end

    def append_check_item(name : String) : MenuItem
      ref_ptr = LibUI.menu_append_check_item(@ref_ptr, name)
      MenuItem.new(ref_ptr)
    end

    def append_check_item(name : String, checked : Bool) : MenuItem
      item = append_check_item(name)
      item.checked = checked
      item
    end

    def append_quit_item : MenuItem
      ref_ptr = LibUI.menu_append_quit_item(@ref_ptr)
      MenuItem.new(ref_ptr)
    end

    def append_preferences_item : MenuItem
      ref_ptr = LibUI.menu_append_preferences_item(@ref_ptr)
      MenuItem.new(ref_ptr)
    end

    def append_about_item : MenuItem
      ref_ptr = LibUI.menu_append_about_item(@ref_ptr)
      MenuItem.new(ref_ptr)
    end

    def append_separator : Nil
      LibUI.menu_append_separator(@ref_ptr)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
