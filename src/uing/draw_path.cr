module UIng
  class DrawPath
    def initialize(@ref_ptr : Pointer(LibUI::DrawPath))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_draw_path
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
