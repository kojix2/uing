require "./control"

module UIng
  class FontButton
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::FontButton))
    end

    def initialize
      @ref_ptr = LibUI.new_font_button
    end

    def on_changed(&block : -> Void)
      UIng.font_button_on_changed(@ref_ptr, &block)
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
