module UIng
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
