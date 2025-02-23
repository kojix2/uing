require "./control"

module UIng
  class RadioButtons
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::RadioButtons))
    end

    def initialize
      @ref_ptr = LibUI.new_radio_buttons
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
