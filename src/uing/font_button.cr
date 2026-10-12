require "./control"

module UIng
  class FontButton < Control
    block_constructor

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize
      @ref_ptr = LibUI.new_font_button
      register_control
    end

    protected def after_destroy : Nil
      @on_changed_box = nil
    end

    # Registers a callback that receives a retainable FontDescriptor.
    def on_changed(&block : FontDescriptor -> Nil) : Nil
      wrapper = -> : Nil {
        font do |font_descriptor|
          block.call(font_descriptor)
        end
      }
      @on_changed_box = ::Box.box(wrapper)
      if boxed_data = @on_changed_box
        LibUI.font_button_on_changed(
          ref_ptr,
          ->(_sender, data) : Nil {
            begin
              data_as_callback = ::Box(typeof(wrapper)).unbox(data)
              data_as_callback.call
            rescue e
              UIng.handle_callback_error(e, "FontButton on_changed")
            end
          },
          boxed_data
        )
      end
    end

    # Yields the selected font as a retainable FontDescriptor.
    def font(&block : FontDescriptor -> Nil) : Nil
      block.call(font)
    end

    # Returns the selected font as a Crystal-managed descriptor.
    def font : FontDescriptor
      FontDescriptor.from_font_button(ref_ptr)
    end

    @[Deprecated("Use `font` to return a FontDescriptor, or `font { ... }` for scoped access")]
    def font(descriptor : FontDescriptor) : Nil
      selected = font
      descriptor.family = selected.family
      descriptor.size = selected.size
      descriptor.weight = selected.weight
      descriptor.italic = selected.italic
      descriptor.stretch = selected.stretch
    end

    def to_unsafe
      ref_ptr
    end
  end
end
