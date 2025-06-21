require "./brush/*"

module UIng
  class Area < Control
    module Draw
      class Brush
        def initialize(@cstruct : LibUI::DrawBrush = LibUI::DrawBrush.new)
        end

        # Single color brush initialization
        def initialize(brush_type : Brush::Type, r : Float64, g : Float64, b : Float64, a : Float64 = 1.0)
          @cstruct = LibUI::DrawBrush.new
          @cstruct.type = brush_type
          @cstruct.r = r
          @cstruct.g = g
          @cstruct.b = b
          @cstruct.a = a
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

        def stops : Pointer(LibUI::DrawBrushGradientStop)
          @cstruct.stops
        end

        def stops=(value : Pointer(LibUI::DrawBrushGradientStop))
          @cstruct.stops = value
        end

        def num_stops : LibC::SizeT
          @cstruct.num_stops
        end

        def num_stops=(value : LibC::SizeT)
          @cstruct.num_stops = value
        end

        def to_unsafe
          pointerof(@cstruct)
        end
      end
    end
  end
end
