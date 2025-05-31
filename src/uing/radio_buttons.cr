require "./control"

module UIng
  class RadioButtons
    include Control; block_constructor

    # Store callback box to prevent GC collection
    @on_selected_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::RadioButtons))
    end

    def initialize
      @ref_ptr = LibUI.new_radio_buttons
    end

    def initialize(items : Array(String))
      initialize()
      items.each do |item|
        append(item)
      end
    end

    def on_selected(&block : LibC::Int -> Void)
      wrapper = -> {
        idx = self.selected
        block.call(idx)
      }
      @on_selected_box = ::Box.box(wrapper)
      UIng.radio_buttons_on_selected(@ref_ptr, @on_selected_box.not_nil!, &wrapper)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
