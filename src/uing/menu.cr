module UIng
  class Menu
    include BlockConstructor; block_constructor

    # Mutex
    @@mutex = Mutex.new

    # Store references to Menu to prevent GC collection
    @@menu : Array(Menu) = [] of Menu

    @@has_quit_item = false
    @@has_preferences_item = false
    @@has_about_item = false

    # Store references to MenuItems to prevent GC collection
    @menu_items : Array(MenuItem) = [] of MenuItem

    def initialize(name : String)
      @ref_ptr = LibUI.new_menu(name)
      @@mutex.synchronize do
        @@menu << self
      end
    end

    def append_item(name : String) : MenuItem
      ref_ptr = LibUI.menu_append_item(@ref_ptr, name)
      item = MenuItem.new(ref_ptr)
      @menu_items << item
      item
    end

    def append_check_item(name : String) : MenuItem
      ref_ptr = LibUI.menu_append_check_item(@ref_ptr, name)
      item = MenuItem.new(ref_ptr)
      @menu_items << item
      item
    end

    def append_check_item(name : String, checked : Bool) : MenuItem
      item = append_check_item(name)
      item.checked = checked
      item
    end

    def append_quit_item : MenuItem
      raise "Quit item already exists" if @@has_quit_item
      ref_ptr = LibUI.menu_append_quit_item(@ref_ptr)
      item = MenuItem.new(ref_ptr)
      @menu_items << item
      @@has_quit_item = true
      item
    end

    def append_preferences_item : MenuItem
      raise "Preferences item already exists" if @@has_preferences_item
      ref_ptr = LibUI.menu_append_preferences_item(@ref_ptr)
      item = MenuItem.new(ref_ptr)
      @menu_items << item
      @@has_preferences_item = true
      item
    end

    def append_about_item : MenuItem
      raise "About item already exists" if @@has_about_item
      ref_ptr = LibUI.menu_append_about_item(@ref_ptr)
      item = MenuItem.new(ref_ptr)
      @menu_items << item
      @@has_about_item = true
      item
    end

    def append_separator : Nil
      LibUI.menu_append_separator(@ref_ptr)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
