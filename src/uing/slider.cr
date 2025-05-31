require "./control"

module UIng
  class Slider
    include Control; block_constructor

    # Store callback boxes to prevent GC collection
    @on_changed_box : Pointer(Void)?
    @on_released_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::Slider))
    end

    def initialize(min, max)
      @ref_ptr = LibUI.new_slider(min, max)
    end

    def initialize(min, max, value)
      @ref_ptr = LibUI.new_slider(min, max)
      self.value = value
    end

    def on_changed(&block : LibC::Int -> Void)
      wrapper = -> {
        v = self.value
        block.call(v)
      }
      @on_changed_box = ::Box.box(wrapper)
      UIng.slider_on_changed(@ref_ptr, @on_changed_box.not_nil!, &wrapper)
    end

    def on_released(&block : LibC::Int -> Void)
      wrapper = -> {
        v = self.value
        block.call(v)
      }
      @on_released_box = ::Box.box(wrapper)
      UIng.slider_on_released(@ref_ptr, @on_released_box.not_nil!, &wrapper)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
