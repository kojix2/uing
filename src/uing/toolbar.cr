module UIng
  # A native toolbar that can be attached to one Window at a time.
  #
  # Toolbar is not a Control. An attached toolbar is freed when its window is
  # destroyed. Detach it first to keep using it. Item icons are copied.
  class Toolbar
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

    def append_toggle_button(text : String, icon : Image? = nil) : ToolbarItem
      check_mutable
      append_item(text, icon, toggle: true)
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
      LibUI.free_toolbar(@ref_ptr)
      @released = true
      @items.each &.__release__
      @items.clear
    end

    def released? : Bool
      @released
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

  # A borrowed item owned by a Toolbar.
  class ToolbarItem
    private enum Kind
      Button
      Toggle
    end

    @released = false
    @on_clicked_box : Pointer(Void)?
    @icon_copy : Image?

    protected def initialize(@toolbar : Toolbar, @ref_ptr : Pointer(LibUI::ToolbarItem), toggle : Bool = false, @icon_copy : Image? = nil)
      @kind = toggle ? Kind::Toggle : Kind::Button
    end

    def text : String?
      UIng.string_from_pointer(LibUI.toolbar_item_text(ref_ptr))
    end

    def text=(text : String) : Nil
      LibUI.toolbar_item_set_text(ref_ptr, text)
    end

    def icon=(icon : Image) : Nil
      item = ref_ptr
      icon_copy = icon.copy
      begin
        LibUI.toolbar_item_set_icon(item, icon_copy.to_unsafe)
        previous_icon = @icon_copy
        @icon_copy = icon_copy
        previous_icon.try &.free
      rescue error
        icon_copy.free
        raise error
      end
    end

    def icon=(icon : Nil) : Nil
      LibUI.toolbar_item_set_icon(ref_ptr, Pointer(LibUI::Image).null)
      @icon_copy.try &.free
      @icon_copy = nil
    end

    def tooltip : String?
      UIng.string_from_pointer(LibUI.toolbar_item_tooltip(ref_ptr))
    end

    def tooltip=(tooltip : String) : Nil
      LibUI.toolbar_item_set_tooltip(ref_ptr, tooltip)
    end

    def enabled? : Bool
      LibUI.toolbar_item_enabled(ref_ptr) != 0
    end

    def enable : Nil
      LibUI.toolbar_item_enable(ref_ptr)
    end

    def disable : Nil
      LibUI.toolbar_item_disable(ref_ptr)
    end

    def checked? : Bool
      item = ref_ptr
      check_toggle_item
      LibUI.toolbar_item_checked(item) != 0
    end

    def checked=(checked : Bool) : Nil
      item = ref_ptr
      check_toggle_item
      LibUI.toolbar_item_set_checked(item, checked ? 1 : 0)
    end

    def on_clicked(&block : ToolbarItem -> Nil) : Nil
      wrapper = -> { block.call(self) }
      @on_clicked_box = ::Box.box(wrapper)
      if boxed_data = @on_clicked_box
        LibUI.toolbar_item_on_clicked(
          ref_ptr,
          ->(_sender, data) : Nil {
            begin
              callback = ::Box(typeof(wrapper)).unbox(data)
              callback.call
            rescue e
              UIng.handle_callback_error(e, "ToolbarItem on_clicked")
            end
          },
          boxed_data
        )
      end
    end

    # Clears the click callback; equivalent to `on_clicked(nil)`.
    def clear_on_clicked : Nil
      LibUI.toolbar_item_on_clicked(ref_ptr, ->(_sender, _data) : Nil { }, Pointer(Void).null)
      @on_clicked_box = nil
    end

    def on_clicked(callback : Nil) : Nil
      clear_on_clicked
    end

    def to_unsafe
      ref_ptr
    end

    # :nodoc:
    protected def __release__ : Nil
      @released = true
      @on_clicked_box = nil
      @icon_copy.try &.free
      @icon_copy = nil
    end

    private def ref_ptr
      raise "ToolbarItem has already been released" if @released
      @toolbar.to_unsafe
      @ref_ptr
    end

    private def check_toggle_item : Nil
      return if @kind.toggle?
      raise ArgumentError.new("checked state is only available for toggle ToolbarItems")
    end
  end
end
