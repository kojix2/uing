module UIng
  # A native toolbar that can be attached to one Window at a time.
  #
  # Toolbar is not a Control. An attached toolbar is freed when its window is
  # destroyed. Detach it first to keep using it. Item icons are copied.
  class Toolbar
    include BlockConstructor; block_constructor

    enum DisplayMode
      IconOnly              = 0
      IconAndTextHorizontal = 1
      IconAndTextVertical   = 2
      TextOnly              = 3
    end

    @released = false
    @ever_attached = false
    @attached_window : Window?
    @items = [] of ToolbarItem

    def initialize
      @ref_ptr = LibUI.new_toolbar
    end

    def append_button(text : String, icon : Image? = nil) : ToolbarItem
      check_mutable
      append_item(text, icon, toggle: false)
    end

    # Configures the new item and returns it, regardless of the block result.
    def append_button(text : String, icon : Image? = nil, &) : ToolbarItem
      item = append_button(text, icon)
      with item yield item
      item
    end

    def append_toggle_button(text : String, icon : Image? = nil) : ToolbarItem
      check_mutable
      append_item(text, icon, toggle: true)
    end

    def append_toggle_button(text : String, icon : Image? = nil, &) : ToolbarItem
      item = append_toggle_button(text, icon)
      with item yield item
      item
    end

    def append_separator : Nil
      check_mutable
      LibUI.toolbar_append_separator(ref_ptr)
    end

    # Returns the requested display mode. The default is
    # `DisplayMode::IconAndTextVertical`.
    def display_mode : DisplayMode
      LibUI.toolbar_get_display_mode(ref_ptr)
    end

    # Sets the display mode, including while attached to a window.
    # macOS displays `DisplayMode::IconAndTextHorizontal` vertically.
    def display_mode=(mode : DisplayMode) : Nil
      check_available
      LibUI.toolbar_set_display_mode(ref_ptr, mode)
    end

    def attached? : Bool
      check_available
      !@attached_window.nil?
    end

    def free : Nil
      return if @released
      raise "Cannot free a Toolbar while it is attached to a Window" if @attached_window
      free_native
      @released = true
      @items.each &.__release__
      @items.clear
    end

    protected def free_native : Nil
      LibUI.free_toolbar(@ref_ptr)
    end

    def released? : Bool
      @released
    end

    protected def __block_constructor_failed__ : Nil
      return if released?
      if window = @attached_window
        window.toolbar = nil
      end
      free
    end

    def to_unsafe
      ref_ptr
    end

    # :nodoc:
    protected def __ensure_attachable__(window : Window) : Nil
      check_available
      if attached_window = @attached_window
        raise "Toolbar is already attached to another Window" unless attached_window.same?(window)
      end
    end

    # :nodoc:
    protected def __attached_by__(window : Window) : Nil
      @attached_window = window
      @ever_attached = true
    end

    # :nodoc:
    protected def __detached_by__(window : Window) : Nil
      @attached_window = nil if @attached_window.same?(window)
    end

    protected def check_available : Nil
      raise "Toolbar has already been released" if @released
    end

    private def check_mutable : Nil
      check_available
      raise "Toolbar items cannot be appended after the toolbar has been attached" if @ever_attached
    end

    private def append_item(text : String, icon : Image?, toggle : Bool) : ToolbarItem
      icon_copy = icon.try &.copy
      begin
        icon_ptr = icon_copy ? icon_copy.to_unsafe : Pointer(LibUI::Image).null
        item_ptr = if toggle
                     LibUI.toolbar_append_toggle_button(ref_ptr, text, icon_ptr)
                   else
                     LibUI.toolbar_append_button(ref_ptr, text, icon_ptr)
                   end
        item = ToolbarItem.new(self, item_ptr, toggle: toggle, icon_copy: icon_copy)
        @items << item
        item
      rescue error
        icon_copy.try &.free
        raise error
      end
    end

    private def ref_ptr
      check_available
      @ref_ptr
    end
  end
end
