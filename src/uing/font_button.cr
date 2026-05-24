require "./control"

module UIng
  class FontButton < Control
    block_constructor

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize
      @ref_ptr = LibUI.new_font_button
    end

    def destroy
      @on_changed_box = nil
      super
    end

    def on_changed(&block : FontDescriptor -> Nil) : Nil
      wrapper = -> : Nil {
        font_descriptor = FontDescriptor.new
        font(font_descriptor)
        begin
          block.call(font_descriptor)
        ensure
          free_font(font_descriptor)
        end
      }
      @on_changed_box = ::Box.box(wrapper)
      if boxed_data = @on_changed_box
        LibUI.font_button_on_changed(
          @ref_ptr,
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

    def font(&block : FontDescriptor -> Nil)
      font_descriptor = FontDescriptor.new
      font(font_descriptor)
      begin
        block.call(font_descriptor)
      ensure
        free_font(font_descriptor)
      end
    end

    def font(descriptor : FontDescriptor)
      descriptor.prepare_for_font_button_font
      LibUI.font_button_font(@ref_ptr, descriptor)
      descriptor.font_button_font_loaded
    end

    def free_font(font_descriptor : FontDescriptor) : Nil
      font_descriptor.free_font_button_font
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
