module UIng
  class Area < Control
    module Draw
      class Path
        include BlockConstructor; block_constructor

        @ended : Bool = false
        @released : Bool = false
        @ref_ptr : Pointer(LibUI::DrawPath)

        def initialize(@ref_ptr : Pointer(LibUI::DrawPath))
        end

        def initialize(mode : FillMode)
          @ref_ptr = LibUI.draw_new_path(mode)
        end

        # Creates a new Path and yields it to the block.
        # - The block must explicitly call end_path before using this path in Context APIs.
        # - The path is always freed after the block, even if an exception occurs.
        # - Returns the block's return value (NOT the Path instance).
        def self.open(mode : FillMode, &)
          instance = new(mode)
          begin
            result = yield instance
          ensure
            instance.free
          end
          result
        end

        private def ensure_not_released
          raise RuntimeError.new("Path is already freed") if @released
        end

        private def ensure_not_ended
          ensure_not_released
          raise RuntimeError.new("Path is already ended") if @ended
        end

        def new_figure(x : Number, y : Number) : self
          ensure_not_ended
          x = NumericValue.finite(x, "path x")
          y = NumericValue.finite(y, "path y")
          LibUI.draw_path_new_figure(@ref_ptr, x, y)
          self
        end

        def new_figure_with_arc(x_center : Number, y_center : Number, radius : Number, start_angle : Number, sweep : Number, negative : Bool) : self
          ensure_not_ended
          x_center = NumericValue.finite(x_center, "path arc x center")
          y_center = NumericValue.finite(y_center, "path arc y center")
          radius = NumericValue.finite(radius, "path arc radius")
          start_angle = NumericValue.finite(start_angle, "path arc start angle")
          sweep = NumericValue.finite(sweep, "path arc sweep")
          LibUI.draw_path_new_figure_with_arc(@ref_ptr, x_center, y_center, radius, start_angle, sweep, negative ? 1 : 0)
          self
        end

        def line_to(x : Number, y : Number) : self
          ensure_not_ended
          x = NumericValue.finite(x, "path x")
          y = NumericValue.finite(y, "path y")
          LibUI.draw_path_line_to(@ref_ptr, x, y)
          self
        end

        def arc_to(x_center : Number, y_center : Number, radius : Number, start_angle : Number, sweep : Number, negative : Bool) : self
          ensure_not_ended
          x_center = NumericValue.finite(x_center, "path arc x center")
          y_center = NumericValue.finite(y_center, "path arc y center")
          radius = NumericValue.finite(radius, "path arc radius")
          start_angle = NumericValue.finite(start_angle, "path arc start angle")
          sweep = NumericValue.finite(sweep, "path arc sweep")
          LibUI.draw_path_arc_to(@ref_ptr, x_center, y_center, radius, start_angle, sweep, negative ? 1 : 0)
          self
        end

        def bezier_to(c1x : Number, c1y : Number, c2x : Number, c2y : Number, end_x : Number, end_y : Number) : self
          ensure_not_ended
          c1x = NumericValue.finite(c1x, "path first control x")
          c1y = NumericValue.finite(c1y, "path first control y")
          c2x = NumericValue.finite(c2x, "path second control x")
          c2y = NumericValue.finite(c2y, "path second control y")
          end_x = NumericValue.finite(end_x, "path end x")
          end_y = NumericValue.finite(end_y, "path end y")
          LibUI.draw_path_bezier_to(@ref_ptr, c1x, c1y, c2x, c2y, end_x, end_y)
          self
        end

        def close_figure : self
          ensure_not_ended
          LibUI.draw_path_close_figure(@ref_ptr)
          self
        end

        def add_rectangle(x : Number, y : Number, width : Number, height : Number) : self
          ensure_not_ended
          x = NumericValue.finite(x, "path rectangle x")
          y = NumericValue.finite(y, "path rectangle y")
          width = NumericValue.finite(width, "path rectangle width")
          height = NumericValue.finite(height, "path rectangle height")
          LibUI.draw_path_add_rectangle(@ref_ptr, x, y, width, height)
          self
        end

        def ended? : Bool
          @ended
        end

        def released? : Bool
          @released
        end

        def end_path : Nil
          ensure_not_released
          return if @ended # Idempotent
          LibUI.draw_path_end(@ref_ptr)
          @ended = true
        end

        def free : Nil
          return if @released # Idempotent
          # Ensure path is ended before freeing (safe even if already ended)
          unless @ended
            LibUI.draw_path_end(@ref_ptr)
            @ended = true
          end
          LibUI.draw_free_path(@ref_ptr)
          @released = true
          # Help catch misuse after free
          @ref_ptr = Pointer(LibUI::DrawPath).null
        end

        def to_unsafe
          ensure_not_released
          @ref_ptr
        end
      end
    end
  end
end
