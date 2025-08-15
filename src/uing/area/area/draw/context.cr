module UIng
  class Area < Control
    module Draw
      class Context
        include BlockConstructor; block_constructor

        def initialize(@ref_ptr : Pointer(LibUI::DrawContext))
        end

        def stroke(path : Path, brush : Brush, stroke_params : StrokeParams) : Nil
          raise ArgumentError.new("Path must be ended before stroking") unless path.ended?
          LibUI.draw_stroke(@ref_ptr, path.to_unsafe, brush.to_unsafe, stroke_params.to_unsafe)
        end

        def stroke(path : Path,
                   brush : Brush,
                   cap : UIng::Area::Draw::LineCap = LineCap::Flat,
                   join : UIng::Area::Draw::LineJoin = LineJoin::Miter,
                   thickness : Number = 1.0,
                   miter_limit : Number = 10.0,
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

        # High-level API: Creates path, yields to block, automatically ends and strokes
        def stroke_path(mode : FillMode, brush : Brush, stroke_params : StrokeParams)
          Path.open(mode) do |path|
            yield path
            path.end_path
            stroke(path, brush, stroke_params)
          end
        end

        def stroke_path(mode : FillMode,
                        brush : Brush,
                        cap : UIng::Area::Draw::LineCap = LineCap::Flat,
                        join : UIng::Area::Draw::LineJoin = LineJoin::Miter,
                        thickness : Number = 1.0,
                        miter_limit : Number = 10.0,
                        dash_phase : Number = 0.0,
                        dashes : Enumerable(Float64)? = nil,
                        &block : Path -> Nil) : Nil
          stroke_params = StrokeParams.new(
            cap: cap,
            join: join,
            thickness: thickness,
            miter_limit: miter_limit,
            dash_phase: dash_phase,
            dashes: dashes
          )
          stroke_path(mode, brush, stroke_params, &block)
        end

        def fill(path : Path, brush : Brush) : Nil
          raise ArgumentError.new("Path must be ended before filling") unless path.ended?
          LibUI.draw_fill(@ref_ptr, path.to_unsafe, brush.to_unsafe)
        end

        # High-level API: Creates path, yields to block, automatically ends and fills
        def fill_path(mode : FillMode, brush : Brush)
          Path.open(mode) do |path|
            yield path
            path.end_path
            fill(path, brush)
          end
        end

        def transform(matrix : Matrix) : Nil
          LibUI.draw_transform(@ref_ptr, matrix.to_unsafe)
        end

        def clip(path : Path) : Nil
          raise ArgumentError.new("Path must be ended before clipping") unless path.ended?
          LibUI.draw_clip(@ref_ptr, path.to_unsafe)
        end

        # High-level API: Creates path, yields to block, automatically ends and clips
        def clip_path(mode : FillMode)
          Path.open(mode) do |path|
            yield path
            path.end_path
            clip(path)
          end
        end

        # High-level API: Creates path, yields to block, can fill and/or stroke
        def draw_path(mode : FillMode,
                      fill : Bool = true,
                      stroke : Bool = false,
                      fill_brush : Brush? = nil,
                      stroke_brush : Brush? = nil,
                      stroke_params : StrokeParams? = nil)
          if fill && fill_brush.nil?
            raise ArgumentError.new("fill=true requires fill_brush")
          end
          if stroke && (stroke_brush.nil? || stroke_params.nil?)
            raise ArgumentError.new("stroke=true requires stroke_brush and stroke_params")
          end

          Path.open(mode) do |path|
            yield path
            path.end_path
            self.fill(path, fill_brush.not_nil!) if fill
            self.stroke(path, stroke_brush.not_nil!, stroke_params.not_nil!) if stroke
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
