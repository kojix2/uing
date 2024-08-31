module UIng
  class DrawTextLayout
    def initialize(@ref_ptr : Pointer(LibUI::DrawTextLayout))
    end

    def initialize
      @ref_ptr = LibUI.new_draw_text_layout
    end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
