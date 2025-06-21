require "./brush/*"

module UIng
  class Area < Control
    module Draw
      class Brush
        include BlockConstructor; block_constructor

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
          @cstruct.r = r.to_f64
          @cstruct.g = g.to_f64
          @cstruct.b = b.to_f64
          @cstruct.a = a.to_f64
          @cstruct.x0 = x0.to_f64
          @cstruct.y0 = y0.to_f64
          @cstruct.x1 = x1.to_f64
          @cstruct.y1 = y1.to_f64
          @cstruct.outer_radius = outer_radius.to_f64

          if stops
            set_gradient_stops(stops)
          else
            @cstruct.stops = Pointer(LibUI::DrawBrushGradientStop).null
            @cstruct.num_stops = 0_u64
          end
        end

        private def set_gradient_stops(stops : Array(GradientStop))
          if stops.empty?
            @cstruct.stops = Pointer(LibUI::DrawBrushGradientStop).null
            @cstruct.num_stops = 0_u64
          else
            # Create array of C structs from GradientStop objects
            c_stops = stops.map(&.to_unsafe.value)
            @cstruct.stops = c_stops.to_unsafe
            @cstruct.num_stops = stops.size.to_u64
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

        def r=(value : Float64)
          @cstruct.r = value
        end

        def g : Float64
          @cstruct.g
        end

        def g=(value : Float64)
          @cstruct.g = value
        end

        def b : Float64
          @cstruct.b
        end

        def b=(value : Float64)
          @cstruct.b = value
        end

        def a : Float64
          @cstruct.a
        end

        def a=(value : Float64)
          @cstruct.a = value
        end

        def x0 : Float64
          @cstruct.x0
        end

        def x0=(value : Float64)
          @cstruct.x0 = value
        end

        def y0 : Float64
          @cstruct.y0
        end

        def y0=(value : Float64)
          @cstruct.y0 = value
        end

        def x1 : Float64
          @cstruct.x1
        end

        def x1=(value : Float64)
          @cstruct.x1 = value
        end

        def y1 : Float64
          @cstruct.y1
        end

        def y1=(value : Float64)
          @cstruct.y1 = value
        end

        def outer_radius : Float64
          @cstruct.outer_radius
        end

        def outer_radius=(value : Float64)
          @cstruct.outer_radius = value
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
