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

    # Registers a callback that receives a block-scoped FontDescriptor.
    # Use FontDescriptor#snapshot to retain the selected font after the
    # callback returns.
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

    # Yields the selected font as a block-scoped FontDescriptor.
    # Use FontDescriptor#snapshot to retain its values after the block returns.
    def font(&block : FontDescriptor -> Nil) : Nil
      font_descriptor = font
      begin
        block.call(font_descriptor)
      ensure
        font_descriptor.free
      end
    end

    # Returns the selected font as an owned descriptor. Call FontDescriptor#free when done.
    def font : FontDescriptor
      descriptor = FontDescriptor.new
      begin
        load_font_into(descriptor)
        descriptor
      rescue error
        descriptor.free
        raise error
      end
    end

    @[Deprecated("Use `font` to return a FontDescriptor, or `font { ... }` for scoped access")]
    def font(descriptor : FontDescriptor) : Nil
      load_font_into(descriptor)
    end

    private def load_font_into(descriptor : FontDescriptor) : Nil
      descriptor.prepare_for_font_button_font
      LibUI.font_button_font(ref_ptr, descriptor)
      descriptor.font_button_font_loaded
    end

    def to_unsafe
      ref_ptr
    end
  end
end
