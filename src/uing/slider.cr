require "./control"

module UIng
  class Slider < Control
    block_constructor

    # Store callback boxes to prevent GC collection
    @on_changed_box : Pointer(Void)?
    @on_released_box : Pointer(Void)?

    def initialize(min, max)
      @ref_ptr = LibUI.new_slider(min, max)
    end

    def destroy
      @on_changed_box = nil
      @on_released_box = nil
      super
    end

    def initialize(min, max, value)
      @ref_ptr = LibUI.new_slider(min, max)
      self.value = value
    end

    def value : Int32
      LibUI.slider_value(@ref_ptr)
    end

    def value=(value : Int32) : Nil
      LibUI.slider_set_value(@ref_ptr, value)
    end

    def has_tool_tip? : Bool
      LibUI.slider_has_tool_tip(@ref_ptr)
    end

    def has_tool_tip=(has_tool_tip : Bool) : Nil
      LibUI.slider_set_has_tool_tip(@ref_ptr, has_tool_tip)
    end

    def set_range(min : Int32, max : Int32) : Nil
      LibUI.slider_set_range(@ref_ptr, min, max)
    end

    def set_range(range : Range(Int32, Int32)) : Nil
      LibUI.slider_set_range(@ref_ptr, range.min, range.max)
    end

    def on_changed(&block : Int32 -> _) : Nil
      wrapper = -> : Nil {
        v = value
        block.call(v)
      }
      @on_changed_box = ::Box.box(wrapper)
      if boxed_data = @on_changed_box
        LibUI.slider_on_changed(
          @ref_ptr,
          ->(_sender, data) : Nil {
            begin
              data_as_callback = ::Box(typeof(wrapper)).unbox(data)
              data_as_callback.call
            rescue e
              UIng.handle_callback_error(e, "Slider on_changed")
            end
          },
          boxed_data
        )
      end
    end

    def on_released(&block : Int32 -> Nil) : Nil
      wrapper = -> : Nil {
        v = value
        block.call(v)
      }
      @on_released_box = ::Box.box(wrapper)
      if boxed_data = @on_released_box
        LibUI.slider_on_released(
          @ref_ptr,
          ->(_sender, data) : Nil {
            begin
              data_as_callback = ::Box(typeof(wrapper)).unbox(data)
              data_as_callback.call
            rescue e
              UIng.handle_callback_error(e, "Slider on_released")
            end
          },
          boxed_data
        )
      end
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
