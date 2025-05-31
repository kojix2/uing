require "./control"

module UIng
  class FontButton
    include Control; block_constructor

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::FontButton))
    end

    def initialize
      @ref_ptr = LibUI.new_font_button
    end

    def on_changed(&block : FontDescriptor -> Void)
      wrapper = -> {
        font_descriptor = FontDescriptor.new
        LibUI.font_button_font(@ref_ptr, font_descriptor)
        block.call(font_descriptor)
        UIng.free_font_descriptor(font_descriptor)
      }
      @on_changed_box = ::Box.box(wrapper)
      UIng.font_button_on_changed(@ref_ptr, @on_changed_box.not_nil!, &wrapper)
    end

    def font(&block : FontDescriptor -> Nil)
      font_descriptor = FontDescriptor.new
      LibUI.font_button_font(@ref_ptr, font_descriptor)
      block.call(font_descriptor)
      UIng.free_font_descriptor(font_descriptor)
    end

    def font(descriptor : (FontDescriptor | LibUI::FontDescriptor))
      LibUI.font_button_font(@ref_ptr, descriptor)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
