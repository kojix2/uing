module UIng
  class DrawTextLayout
    @released = false

    def initialize(@ref_ptr : Pointer(LibUI::DrawTextLayout))
    end

    def free : Nil
      return if @released
      LibUI.draw_free_text_layout(@ref_ptr)
      @released = true
    end

    def extents : {LibC::Double, LibC::Double}
      LibUI.draw_text_layout_extents(@ref_ptr, out width, out height)
      {width, height}
    end

    def to_unsafe
      @ref_ptr
    end

    def finalize
      free
    end
  end
end
