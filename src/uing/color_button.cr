require "./control"

module UIng
  class ColorButton
    include Control; block_constructor

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::ColorButton))
    end

    def initialize
      @ref_ptr = LibUI.new_color_button
    end

    def on_changed(&block : Float64, Float64, Float64, Float64 -> Void)
      wrapper = -> {
        LibUI.color_button_color(@ref_ptr, out r, out g, out b, out a)
        block.call(r, g, b, a)
      }
      @on_changed_box = ::Box.box(wrapper)
      UIng.color_button_on_changed(@ref_ptr, @on_changed_box.not_nil!, &wrapper)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
