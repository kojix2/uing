module UIng
  class Area < Control
    module Draw
      class Context
        def initialize(@ref_ptr : Pointer(LibUI::DrawContext))
        end

        def stroke(draw_path : Path, draw_brush : Brush, draw_stroke_params : StrokeParams) : Nil
          LibUI.draw_stroke(@ref_ptr, draw_path.to_unsafe, draw_brush.to_unsafe, draw_stroke_params.to_unsafe)
        end

        def stroke(draw_path : Path,
                   draw_brush : Brush,
                   cap : UIng::Area::Draw::LineCap? = nil,
                   join : UIng::Area::Draw::LineJoin? = nil,
                   thickness : Number? = nil,
                   miter_limit : Number? = nil,
                   dash_phase : Number? = nil,
                   dashes : Enumerable(Float64)? = nil) : Nil
          stroke_params = StrokeParams.new(
            cap: cap,
            join: join,
            thickness: thickness,
            miter_limit: miter_limit,
            dash_phase: dash_phase,
            dashes: dashes
          )
          stroke(draw_path, draw_brush, stroke_params)
        end

        def fill(draw_path : Path, draw_brush : Brush) : Nil
          LibUI.draw_fill(@ref_ptr, draw_path.to_unsafe, draw_brush.to_unsafe)
        end

        def transform(draw_matrix : DrawMatrix) : Nil
          LibUI.draw_transform(@ref_ptr, draw_matrix.to_unsafe)
        end

        def clip(draw_path : Path) : Nil
          LibUI.draw_clip(@ref_ptr, draw_path.to_unsafe)
        end

        def save : Nil
          LibUI.draw_save(@ref_ptr)
        end

        def restore : Nil
          LibUI.draw_restore(@ref_ptr)
        end

        def text(draw_text_layout : TextLayout, x : Float64, y : Float64) : Nil
          LibUI.draw_text(@ref_ptr, draw_text_layout.to_unsafe, x, y)
        end

        def to_unsafe
          @ref_ptr
        end
      end
    end
  end
end
