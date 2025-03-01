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

    def to_unsafe
      @ref_ptr
    end
  end
end
