module UIng
  class Area < Control
    module Draw
      class Context
        include BlockConstructor; block_constructor

        def initialize(@ref_ptr : Pointer(LibUI::DrawContext))
        end

        # Low-level: stroke an ended path
        def draw_stroke(path : Path, brush : Brush, stroke_params : StrokeParams) : Nil
          raise ArgumentError.new("Path must be ended before stroking") unless path.ended?
          LibUI.draw_stroke(@ref_ptr, path.to_unsafe, brush.to_unsafe, stroke_params.to_unsafe)
        end

        # Convenience overload to build StrokeParams inline
        def draw_stroke(path : Path,
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
          draw_stroke(path, brush, stroke_params)
        end

        # High-level: build a path in a block, end it, and stroke
        def stroke_path(brush : Brush, stroke_params : StrokeParams, mode : FillMode = FillMode::Winding, &)
          Path.open(mode) do |path|
            yield path
            path.end_path
            draw_stroke(path, brush, stroke_params)
          end
        end

        def stroke_path(brush : Brush,
                        cap : UIng::Area::Draw::LineCap = LineCap::Flat,
                        join : UIng::Area::Draw::LineJoin = LineJoin::Miter,
                        thickness : Number = 1.0,
                        miter_limit : Number = 10.0,
                        dash_phase : Number = 0.0,
                        dashes : Enumerable(Float64)? = nil,
                        mode : FillMode = FillMode::Winding,
                        &block : Path -> Nil) : Nil
          stroke_params = StrokeParams.new(
            cap: cap,
            join: join,
            thickness: thickness,
            miter_limit: miter_limit,
            dash_phase: dash_phase,
            dashes: dashes
          )
          stroke_path(brush, stroke_params, mode, &block)
        end

        # Low-level: fill an ended path
        def draw_fill(path : Path, brush : Brush) : Nil
          raise ArgumentError.new("Path must be ended before filling") unless path.ended?
          LibUI.draw_fill(@ref_ptr, path.to_unsafe, brush.to_unsafe)
        end

        # High-level: build a path in a block, end it, and fill
        def fill_path(brush : Brush, mode : FillMode = FillMode::Winding, &)
          Path.open(mode) do |path|
            yield path
            path.end_path
            draw_fill(path, brush)
          end
        end

        # Matrix composition (same semantics as libui's uiDrawTransform)
        def transform(matrix : Matrix) : Nil
          LibUI.draw_transform(@ref_ptr, matrix.to_unsafe)
        end

        # Low-level clipping: apply a finished path as clip
        def clip(path : Path) : Nil
          raise ArgumentError.new("Path must be ended before clipping") unless path.ended?
          LibUI.draw_clip(@ref_ptr, path.to_unsafe)
        end

        # High-level clipping: build a path in a block, end it, and clip
        def clip_path(mode : FillMode = FillMode::Winding, &)
          Path.open(mode) do |path|
            yield path
            path.end_path
            clip(path)
          end
        end

        # High-level: build once, then optionally fill and/or stroke
        def draw_path(mode : FillMode = FillMode::Winding,
                      fill : Bool = true,
                      stroke : Bool = false,
                      fill_brush : Brush? = nil,
                      stroke_brush : Brush? = nil,
                      stroke_params : StrokeParams? = nil, &)
          if fill && fill_brush.nil?
            raise ArgumentError.new("fill=true requires fill_brush")
          end
          if stroke && (stroke_brush.nil? || stroke_params.nil?)
            raise ArgumentError.new("stroke=true requires stroke_brush and stroke_params")
          end

          Path.open(mode) do |path|
            yield path
            path.end_path
            self.draw_fill(path, fill_brush.not_nil!) if fill
            self.draw_stroke(path, stroke_brush.not_nil!, stroke_params.not_nil!) if stroke
          end
        end

        # Save/restore helpers
        def save : Nil
          LibUI.draw_save(@ref_ptr)
        end

        def restore : Nil
          LibUI.draw_restore(@ref_ptr)
        end

        # Text drawing (libui uiDrawText equivalent)
        def draw_text_layout(text_layout : TextLayout, x : Float64, y : Float64) : Nil
          LibUI.draw_text(@ref_ptr, text_layout.to_unsafe, x, y)
        end

        def to_unsafe
          @ref_ptr
        end
      end
    end
  end
end
