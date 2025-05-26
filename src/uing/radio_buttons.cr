require "./control"

module UIng
  class RadioButtons
    include Control

    # Store callback box to prevent GC collection
    @on_selected_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::RadioButtons))
    end

    def initialize
      @ref_ptr = LibUI.new_radio_buttons
    end

    def on_selected(&block : -> Void)
      @on_selected_box = ::Box.box(block)
      UIng.radio_buttons_on_selected(@ref_ptr, @on_selected_box.not_nil!, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
