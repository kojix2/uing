require "./control"

module UIng
  class RadioButtons < Control
    block_constructor

    @released : Bool = false

    # Store callback box to prevent GC collection
    @on_selected_box : Pointer(Void)?

    def initialize
      @ref_ptr = LibUI.new_radio_buttons
    end

    def destroy
      return if @released
      @on_selected_box = nil
      super.tap { @released = true }
    end

    def initialize(items : Array(String))
      initialize()
      items.each do |item|
        append(item)
      end
    end

    def append(text : String) : Nil
      LibUI.radio_buttons_append(@ref_ptr, text)
    end

    def selected : Int32
      LibUI.radio_buttons_selected(@ref_ptr)
    end

    def selected=(index : Int32) : Nil
      LibUI.radio_buttons_set_selected(@ref_ptr, index)
    end

    def on_selected(&block : Int32 -> Void)
      wrapper = -> {
        idx = self.selected
        block.call(idx)
      }
      @on_selected_box = ::Box.box(wrapper)
      LibUI.radio_buttons_on_selected(@ref_ptr, ->(sender, data) do
        begin
          data_as_callback = ::Box(typeof(wrapper)).unbox(data)
          data_as_callback.call
        rescue e
          UIng.handle_callback_error(e, "RadioButtons on_selected")
        end
      end, @on_selected_box.not_nil!)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
