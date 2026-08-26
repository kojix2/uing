module UIng
  # A native toolbar that can be attached to one Window at a time.
  #
  # Toolbar is not a Control. Free it explicitly after detaching it from its
  # window. Images passed to toolbar items are borrowed by libui-ng and must
  # remain alive until the toolbar is freed.
  class Toolbar
    @released = false
    @ever_attached = false
    @attached_window : Window?
    @items = [] of ToolbarItem
    @image_refs = [] of Image

    def initialize
      @ref_ptr = LibUI.new_toolbar
    end

    def append_button(text : String, icon : Image? = nil) : ToolbarItem
      check_mutable
      retain(icon)
      item = ToolbarItem.new(self, LibUI.toolbar_append_button(ref_ptr, text, image_pointer(icon)))
      @items << item
      item
    end

    def append_toggle_button(text : String, icon : Image? = nil) : ToolbarItem
      check_mutable
      retain(icon)
      item = ToolbarItem.new(self, LibUI.toolbar_append_toggle_button(ref_ptr, text, image_pointer(icon)))
      @items << item
      item
    end

    def append_separator : Nil
      check_mutable
      LibUI.toolbar_append_separator(ref_ptr)
    end

    def append_space : Nil
      check_mutable
      LibUI.toolbar_append_space(ref_ptr)
    end

    def append_flexible_space : Nil
      check_mutable
      LibUI.toolbar_append_flexible_space(ref_ptr)
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
      @image_refs.clear
    end

    def released? : Bool
      @released
    end

    def to_unsafe
      ref_ptr
    end

    # :nodoc:
    def __ensure_attachable__(window : Window) : Nil
      check_available
      if attached_window = @attached_window
        raise "Toolbar is already attached to another Window" unless attached_window.same?(window)
      end
    end

    # :nodoc:
    def __attached_by__(window : Window) : Nil
      @attached_window = window
      @ever_attached = true
    end

    # :nodoc:
    def __detached_by__(window : Window) : Nil
      @attached_window = nil if @attached_window.same?(window)
    end

    # :nodoc:
    def __retain_image__(image : Image) : Nil
      check_available
      image.to_unsafe
      retain(image)
    end

    protected def check_available : Nil
      raise "Toolbar has already been released" if @released
    end

    private def check_mutable : Nil
      check_available
      raise "Toolbar items cannot be appended after the toolbar has been attached" if @ever_attached
    end

    private def retain(image : Image?) : Nil
      @image_refs << image if image && !@image_refs.includes?(image)
    end

    private def image_pointer(image : Image?) : Pointer(LibUI::Image)
      image ? image.to_unsafe : Pointer(LibUI::Image).null
    end

    private def ref_ptr
      check_available
      @ref_ptr
    end
  end

  # A borrowed item owned by a Toolbar.
  class ToolbarItem
    @released = false
    @on_clicked_box : Pointer(Void)?

    protected def initialize(@toolbar : Toolbar, @ref_ptr : Pointer(LibUI::ToolbarItem))
    end

    def text : String?
      UIng.string_from_pointer(LibUI.toolbar_item_text(ref_ptr))
    end

    def text=(text : String) : Nil
      LibUI.toolbar_item_set_text(ref_ptr, text)
    end

    def icon=(icon : Image) : Nil
      @toolbar.__retain_image__(icon)
      LibUI.toolbar_item_set_icon(ref_ptr, icon.to_unsafe)
    end

    def icon=(icon : Nil) : Nil
      LibUI.toolbar_item_set_icon(ref_ptr, Pointer(LibUI::Image).null)
    end

    def tooltip : String?
      UIng.string_from_pointer(LibUI.toolbar_item_tooltip(ref_ptr))
    end

    def tooltip=(tooltip : String) : Nil
      LibUI.toolbar_item_set_tooltip(ref_ptr, tooltip)
    end

    def enabled? : Bool
      LibUI.toolbar_item_enabled(ref_ptr)
    end

    def enable : Nil
      LibUI.toolbar_item_enable(ref_ptr)
    end

    def disable : Nil
      LibUI.toolbar_item_disable(ref_ptr)
    end

    def checked? : Bool
      LibUI.toolbar_item_checked(ref_ptr)
    end

    def checked=(checked : Bool) : Nil
      LibUI.toolbar_item_set_checked(ref_ptr, checked)
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

    def to_unsafe
      ref_ptr
    end

    # :nodoc:
    def __release__ : Nil
      @released = true
      @on_clicked_box = nil
    end

    private def ref_ptr
      raise "ToolbarItem has already been released" if @released
      @toolbar.to_unsafe
      @ref_ptr
    end
  end
end
