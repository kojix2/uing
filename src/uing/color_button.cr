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
        r = uninitialized Float64
        g = uninitialized Float64
        b = uninitialized Float64
        a = uninitialized Float64
        LibUI.color_button_color(@ref_ptr, pointerof(r), pointerof(g), pointerof(b), pointerof(a))
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
