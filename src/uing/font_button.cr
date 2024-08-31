module UIng
  class FontButton
    def initialize(@ref_ptr : Pointer(LibUI::FontButton))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_font_button
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
