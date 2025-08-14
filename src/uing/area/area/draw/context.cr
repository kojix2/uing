module UIng
  class Area < Control
    module Draw
      class Context
        include BlockConstructor; block_constructor

        def initialize(@ref_ptr : Pointer(LibUI::DrawContext))
        end

        def stroke(path : Path, brush : Brush, stroke_params : StrokeParams) : Nil
          LibUI.draw_stroke(@ref_ptr, path.to_unsafe, brush.to_unsafe, stroke_params.to_unsafe)
        end

        def stroke(path : Path,
                   brush : Brush,
                   cap : UIng::Area::Draw::LineCap = LineCap::Flat,
                   join : UIng::Area::Draw::LineJoin? = LineJoin::Miter,
                   thickness : Number = 0.0,
                   miter_limit : Number = 0.0,
                   dash_phase : Number = 0.0,
                   dashes : Enumerable(Float64)? = nil) : Nil
          stroke_params = StrokeParams.new(
            cap: cap,
            join: join,
            thickness: thickness,
            miter_limit: miter_limit,
            dash_phase: dash_phase,
            dashes: dashes
          )
          stroke(path, brush, stroke_params)
        end

        def stroke(mode : FillMode,
                   brush : Brush,
                   stroke_params : StrokeParams,
                   &block) : Nil
          Path.open(mode) do |path|
            yield path
            stroke(path, brush, stroke_params)
          end
        end

        def stroke(mode : FillMode,
                   brush : Brush,
                   cap : UIng::Area::Draw::LineCap = LineCap::Flat,
                   join : UIng::Area::Draw::LineJoin? = LineJoin::Miter,
                   thickness : Number = 0.0,
                   miter_limit : Number = 0.0,
                   dash_phase : Number = 0.0,
                   dashes : Enumerable(Float64)? = nil,
                   &block) : Nil
          Path.open(mode) do |path|
            yield path
            stroke(path, brush, cap: cap, join: join, thickness: thickness, miter_limit: miter_limit, dash_phase: dash_phase, dashes: dashes)
          end
        end

        def fill(path : Path, brush : Brush) : Nil
          LibUI.draw_fill(@ref_ptr, path.to_unsafe, brush.to_unsafe)
        end

        def fill(mode : FillMode, brush : Brush, &block) : Nil
          Path.open(mode) do |path|
            yield path
            fill(path, brush)
          end
        end

        def transform(matrix : Matrix) : Nil
          LibUI.draw_transform(@ref_ptr, matrix.to_unsafe)
        end

        def clip(path : Path) : Nil
          LibUI.draw_clip(@ref_ptr, path.to_unsafe)
        end

        def clip(mode : FillMode, &block) : Nil
          Path.open(mode) do |path|
            yield path
            clip(path)
          end
        end

        def save : Nil
          LibUI.draw_save(@ref_ptr)
        end

        def restore : Nil
          LibUI.draw_restore(@ref_ptr)
        end

        def text(text_layout : TextLayout, x : Float64, y : Float64) : Nil
          LibUI.draw_text(@ref_ptr, text_layout.to_unsafe, x, y)
        end

        def to_unsafe
          @ref_ptr
        end
      end
    end
  end
end
