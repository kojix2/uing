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
    @released : Bool = false

    def initialize(name : String)
      @ref_ptr = LibUI.new_menu(name)
      @@mutex.synchronize do
        @@menu << self
      end
    end

    def append_item(name : String) : MenuItem
      check_available
      ref_ptr = LibUI.menu_append_item(@ref_ptr, name)
      item = MenuItem.new(ref_ptr)
      @menu_items << item
      item
    end

    def append_check_item(name : String) : MenuItem
      check_available
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
      check_available
      raise "Quit item already exists" if @@has_quit_item
      ref_ptr = LibUI.menu_append_quit_item(@ref_ptr)
      item = MenuItem.new(ref_ptr)
      @menu_items << item
      @@has_quit_item = true
      item
    end

    def append_preferences_item : MenuItem
      check_available
      raise "Preferences item already exists" if @@has_preferences_item
      ref_ptr = LibUI.menu_append_preferences_item(@ref_ptr)
      item = MenuItem.new(ref_ptr)
      @menu_items << item
      @@has_preferences_item = true
      item
    end

    def append_about_item : MenuItem
      check_available
      raise "About item already exists" if @@has_about_item
      ref_ptr = LibUI.menu_append_about_item(@ref_ptr)
      item = MenuItem.new(ref_ptr)
      @menu_items << item
      @@has_about_item = true
      item
    end

    def append_separator : Nil
      check_available
      LibUI.menu_append_separator(@ref_ptr)
    end

    def to_unsafe
      check_available
      @ref_ptr
    end

    # :nodoc:
    def self.reset_after_uninit : Nil
      @@mutex.synchronize do
        @@menu.each(&.invalidate_after_uninit)
        @@menu.clear
        @@has_quit_item = false
        @@has_preferences_item = false
        @@has_about_item = false
      end
    end

    # :nodoc:
    protected def invalidate_after_uninit : Nil
      return if @released
      @released = true
      @menu_items.each(&.invalidate_after_uninit)
      @menu_items.clear
    end

    private def check_available : Nil
      raise "Menu has already been released" if @released
    end
  end
end
