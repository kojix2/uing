require "./control"

module UIng
  class FontButton < Control
    block_constructor

    @released : Bool = false

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize
      @ref_ptr = LibUI.new_font_button
    end

    def destroy
      return if @released
      @on_changed_box = nil
      super.tap { @released = true }
    end

    def on_changed(&block : FontDescriptor -> Void)
      wrapper = -> {
        font_descriptor = FontDescriptor.new
        self.font(font_descriptor)
        block.call(font_descriptor)
        free_font(font_descriptor)
      }
      @on_changed_box = ::Box.box(wrapper)
      boxed_data = @on_changed_box.not_nil!
      LibUI.font_button_on_changed(@ref_ptr, ->(sender, data) do
        begin
          data_as_callback = ::Box(typeof(wrapper)).unbox(data)
          data_as_callback.call
        rescue e
          UIng.handle_callback_error(e, "FontButton on_changed")
        end
      end, boxed_data)
    end

    def font(&block : FontDescriptor -> Nil)
      font_descriptor = FontDescriptor.new
      self.font(font_descriptor)
      block.call(font_descriptor)
      free_font(font_descriptor)
    end

    def font(descriptor : FontDescriptor)
      LibUI.font_button_font(@ref_ptr, descriptor)
    end

    def free_font(font_descriptor : FontDescriptor) : Nil
      LibUI.free_font_button_font(font_descriptor.to_unsafe)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
