require "./control"

module UIng
  class RadioButtons
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::RadioButtons))
    end

    def initialize
      @ref_ptr = LibUI.new_radio_buttons
    end

    def on_selected(&block : -> Void)
      UIng.radio_buttons_on_selected(@ref_ptr, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
