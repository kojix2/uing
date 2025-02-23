require "./control"

module UIng
  class FontButton
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::FontButton))
    end

    def initialize
      @ref_ptr = LibUI.new_font_button
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
