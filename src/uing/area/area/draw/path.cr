module UIng
  class Area < Control
    module Draw
      class Path
        include BlockConstructor; block_constructor

        @released = false

        def initialize(@ref_ptr : Pointer(LibUI::DrawPath))
        end

        def initialize(mode : FillMode)
          @ref_ptr = LibUI.draw_new_path(mode)
        end

        # Creates a new Path and yields it to the block.
        # After the block execution, it automatically ends the path.
        def self.open(mode : FillMode, &block) : Path
          instance = new(mode)
          with instance yield(instance)
          instance.end_path unless instance.ended?
          instance
        end

        # Yields the current Path to the block, after ensuring the path is ended.
        # And frees the path after the block execution.
        def with(& : Path -> Nil) : Nil
          begin
            yield self
          ensure
            free
          end
        end

        def end_with(& : Path -> Nil) : Nil
          end_path
          begin
            yield self
          ensure
            free
          end
        end

        def new_figure(x : Float64, y : Float64) : self
          LibUI.draw_path_new_figure(@ref_ptr, x, y)
          self
        end

        def new_figure_with_arc(x_center : Float64, y_center : Float64, radius : Float64, start_angle : Float64, sweep : Float64, negative : Bool) : self
          LibUI.draw_path_new_figure_with_arc(@ref_ptr, x_center, y_center, radius, start_angle, sweep, negative)
          self
        end

        def line_to(x : Float64, y : Float64) : self
          LibUI.draw_path_line_to(@ref_ptr, x, y)
          self
        end

        def arc_to(x_center : Float64, y_center : Float64, radius : Float64, start_angle : Float64, sweep : Float64, negative : Bool) : self
          LibUI.draw_path_arc_to(@ref_ptr, x_center, y_center, radius, start_angle, sweep, negative)
          self
        end

        def bezier_to(c1x : Float64, c1y : Float64, c2x : Float64, c2y : Float64, end_x : Float64, end_y : Float64) : self
          LibUI.draw_path_bezier_to(@ref_ptr, c1x, c1y, c2x, c2y, end_x, end_y)
          self
        end

        def close_figure : self
          LibUI.draw_path_close_figure(@ref_ptr)
          self
        end

        def add_rectangle(x : Float64, y : Float64, width : Float64, height : Float64) : self
          LibUI.draw_path_add_rectangle(@ref_ptr, x, y, width, height)
          self
        end

        def ended? : Bool
          LibUI.draw_path_ended(@ref_ptr)
        end

        def end_ : Nil
          end_path
        end

        def end_path : Nil
          LibUI.draw_path_end(@ref_ptr)
        end

        def free : Nil
          return if @released
          LibUI.draw_free_path(@ref_ptr)
          @released = true
        end

        def to_unsafe
          @ref_ptr
        end
      end
    end
  end
end
