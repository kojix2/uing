module UIng
  class DrawPath
    include MethodMissing

    def initialize(@ref_ptr : Pointer(LibUI::DrawPath))
    end

    def initialize(mode : LibUI::DrawFillMode)
      @ref_ptr = LibUI.new_draw_path(mode)
    end

    def to_unsafe
      @ref_ptr
    end

    # def finalize
    #   LibUI.draw_free_path(@ref_ptr)
    # end
  end
end
