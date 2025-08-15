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
        def self.open(mode : FillMode)
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

        def new_figure(x : Float64, y : Float64) : self
          ensure_not_ended
          LibUI.draw_path_new_figure(@ref_ptr, x, y)
          self
        end

        def new_figure_with_arc(x_center : Float64, y_center : Float64, radius : Float64, start_angle : Float64, sweep : Float64, negative : Bool) : self
          ensure_not_ended
          LibUI.draw_path_new_figure_with_arc(@ref_ptr, x_center, y_center, radius, start_angle, sweep, negative)
          self
        end

        def line_to(x : Float64, y : Float64) : self
          ensure_not_ended
          LibUI.draw_path_line_to(@ref_ptr, x, y)
          self
        end

        def arc_to(x_center : Float64, y_center : Float64, radius : Float64, start_angle : Float64, sweep : Float64, negative : Bool) : self
          ensure_not_ended
          LibUI.draw_path_arc_to(@ref_ptr, x_center, y_center, radius, start_angle, sweep, negative)
          self
        end

        def bezier_to(c1x : Float64, c1y : Float64, c2x : Float64, c2y : Float64, end_x : Float64, end_y : Float64) : self
          ensure_not_ended
          LibUI.draw_path_bezier_to(@ref_ptr, c1x, c1y, c2x, c2y, end_x, end_y)
          self
        end

        def close_figure : self
          ensure_not_ended
          LibUI.draw_path_close_figure(@ref_ptr)
          self
        end

        def add_rectangle(x : Float64, y : Float64, width : Float64, height : Float64) : self
          ensure_not_ended
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
