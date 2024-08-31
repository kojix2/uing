module UIng
  class DrawContext
    def initialize(@ref_ptr : Pointer(LibUI::DrawContext))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_draw_context
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
