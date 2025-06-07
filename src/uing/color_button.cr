require "./control"

module UIng
  class ColorButton < Control
    block_constructor
    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::ColorButton))
    end

    def initialize
      @ref_ptr = LibUI.new_color_button
    end

    def color : {Float64, Float64, Float64, Float64}
      LibUI.color_button_color(@ref_ptr, out r, out g, out b, out a)
      {r, g, b, a}
    end

    def set_color(r : Float64, g : Float64, b : Float64, a : Float64) : Nil
      LibUI.color_button_set_color(@ref_ptr, r, g, b, a)
    end

    def on_changed(&block : Float64, Float64, Float64, Float64 -> Void)
      wrapper = -> {
        r, g, b, a = self.color
        block.call(r, g, b, a)
      }
      @on_changed_box = ::Box.box(wrapper)
      LibUI.color_button_on_changed(@ref_ptr, ->(sender, data) do
        data_as_callback = ::Box(typeof(wrapper)).unbox(data)
        data_as_callback.call
      end, @on_changed_box.not_nil!)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
