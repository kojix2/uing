module UIng
  class RadioButtons
    def initialize(@ref_ptr : Pointer(LibUI::RadioButtons))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_radio_buttons
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
