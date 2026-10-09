require "./brush/*"

module UIng
  class Area < Control
    module Draw
      class Brush
        include BlockConstructor; block_constructor

        # FIX: Keep gradient stops buffer alive for C-side pointer lifetime management
        @stops_buffer : Array(LibUI::DrawBrushGradientStop) = [] of LibUI::DrawBrushGradientStop

        def initialize(type : Brush::Type,
                       r : Number = 0.0,
                       g : Number = 0.0,
                       b : Number = 0.0,
                       a : Number = 1.0,
                       x0 : Number = 0.0,
                       y0 : Number = 0.0,
                       x1 : Number = 0.0,
                       y1 : Number = 0.0,
                       outer_radius : Number = 0.0,
                       stops : Array(GradientStop)? = nil)
          @cstruct = LibUI::DrawBrush.new
          @cstruct.type = type
          self.r = r
          self.g = g
          self.b = b
          self.a = a
          self.x0 = x0
          self.y0 = y0
          self.x1 = x1
          self.y1 = y1
          self.outer_radius = outer_radius

          if stops
            set_gradient_stops(stops)
          else
            @stops_buffer.clear
            @cstruct.stops = Pointer(LibUI::DrawBrushGradientStop).null
            @cstruct.num_stops = 0_u64
          end
        end

        private def set_gradient_stops(stops : Array(GradientStop))
          if stops.empty?
            @stops_buffer.clear
            @cstruct.stops = Pointer(LibUI::DrawBrushGradientStop).null
            @cstruct.num_stops = 0_u64
          else
            # FIX: Store C structs in instance variable to keep them alive
            # Crystal's Array.to_unsafe is guaranteed to be C-compatible
            @stops_buffer = Array(LibUI::DrawBrushGradientStop).new(stops.size)
            stops.each do |gradient_stop|
              @stops_buffer << gradient_stop.to_unsafe.value
            end
            @cstruct.stops = @stops_buffer.to_unsafe
            @cstruct.num_stops = @stops_buffer.size.to_u64
          end
        end

        def type : Type
          @cstruct.type
        end

        def type=(value : Type)
          @cstruct.type = value
        end

        def r : Float64
          @cstruct.r
        end

        def r=(value : Number)
          @cstruct.r = NumericValue.unit_interval(value, "brush red")
        end

        def g : Float64
          @cstruct.g
        end

        def g=(value : Number)
          @cstruct.g = NumericValue.unit_interval(value, "brush green")
        end

        def b : Float64
          @cstruct.b
        end

        def b=(value : Number)
          @cstruct.b = NumericValue.unit_interval(value, "brush blue")
        end

        def a : Float64
          @cstruct.a
        end

        def a=(value : Number)
          @cstruct.a = NumericValue.unit_interval(value, "brush alpha")
        end

        def x0 : Float64
          @cstruct.x0
        end

        def x0=(value : Number)
          @cstruct.x0 = NumericValue.finite(value, "brush x0")
        end

        def y0 : Float64
          @cstruct.y0
        end

        def y0=(value : Number)
          @cstruct.y0 = NumericValue.finite(value, "brush y0")
        end

        def x1 : Float64
          @cstruct.x1
        end

        def x1=(value : Number)
          @cstruct.x1 = NumericValue.finite(value, "brush x1")
        end

        def y1 : Float64
          @cstruct.y1
        end

        def y1=(value : Number)
          @cstruct.y1 = NumericValue.finite(value, "brush y1")
        end

        def outer_radius : Float64
          @cstruct.outer_radius
        end

        def outer_radius=(value : Number)
          @cstruct.outer_radius = NumericValue.finite(value, "brush outer radius")
        end

        def stops : Array(GradientStop)
          return Array(GradientStop).new if @cstruct.num_stops == 0 || @cstruct.stops.null?

          Array(GradientStop).new(@cstruct.num_stops.to_i) do |i|
            c_stop = (@cstruct.stops + i).value
            GradientStop.new(
              pos: c_stop.pos,
              r: c_stop.r,
              g: c_stop.g,
              b: c_stop.b,
              a: c_stop.a
            )
          end
        end

        def stops=(value : Array(GradientStop))
          set_gradient_stops(value)
        end

        def num_stops : LibC::SizeT
          @cstruct.num_stops
        end

        def to_unsafe
          pointerof(@cstruct)
        end
      end
    end
  end
end
