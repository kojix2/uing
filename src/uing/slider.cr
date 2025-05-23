require "./control"

module UIng
  class Slider
    include Control

    # Store callback boxes to prevent GC collection
    @on_changed_box : Pointer(Void)?
    @on_released_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::Slider))
    end

    def initialize(min, max)
      @ref_ptr = LibUI.new_slider(min, max)
    end

    def on_changed(&block : -> Void)
      @on_changed_box = ::Box.box(block)
      UIng.slider_on_changed(@ref_ptr, @on_changed_box.not_nil!, &block)
    end

    def on_released(&block : -> Void)
      @on_released_box = ::Box.box(block)
      UIng.slider_on_released(@ref_ptr, @on_released_box.not_nil!, &block)
    end

    def to_unsafe
      @ref_ptr
    end

    def value=(value : Int32)
      set_value(value)
    end

    def has_tool_tip=(value : Bool)
      set_has_tool_tip(value ? 1 : 0)
    end
  end
end
