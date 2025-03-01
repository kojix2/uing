require "./control"

module UIng
  class ColorButton
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::ColorButton))
    end

    def initialize
      @ref_ptr = LibUI.new_color_button
    end

    def on_changed(&block : -> Void)
      UIng.color_button_on_changed(@ref_ptr, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
