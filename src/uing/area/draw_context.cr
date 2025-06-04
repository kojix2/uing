module UIng
  class DrawContext
    def initialize(@ref_ptr : Pointer(LibUI::DrawContext))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_draw_context
    # end

    def stroke(draw_path : DrawPath, draw_brush : DrawBrush, draw_stroke_params : DrawStrokeParams) : Nil
      LibUI.draw_stroke(@ref_ptr, draw_path.to_unsafe, draw_brush.to_unsafe, draw_stroke_params.to_unsafe)
    end

    def fill(draw_path : DrawPath, draw_brush : DrawBrush) : Nil
      LibUI.draw_fill(@ref_ptr, draw_path.to_unsafe, draw_brush.to_unsafe)
    end

    def transform(draw_matrix : DrawMatrix) : Nil
      LibUI.draw_transform(@ref_ptr, draw_matrix.to_unsafe)
    end

    def clip(draw_path : DrawPath) : Nil
      LibUI.draw_clip(@ref_ptr, draw_path.to_unsafe)
    end

    def save : Nil
      LibUI.draw_save(@ref_ptr)
    end

    def restore : Nil
      LibUI.draw_restore(@ref_ptr)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
