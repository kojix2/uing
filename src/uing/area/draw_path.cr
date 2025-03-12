module UIng
  class DrawPath
    include MethodMissing

    def initialize(@ref_ptr : Pointer(LibUI::DrawPath))
    end

    def initialize(mode : UIng::DrawFillMode)
      @ref_ptr = LibUI.draw_new_path(mode)
    end

    def to_unsafe
      @ref_ptr
    end

    def end
      # Workaround for the naming conflict with the `end` keyword
      LibUI.draw_path_end(@ref_ptr)
    end

    def end_
      LibUI.draw_path_end(@ref_ptr)
    end

    # def finalize
    #   LibUI.draw_free_path(@ref_ptr)
    # end
  end
end
