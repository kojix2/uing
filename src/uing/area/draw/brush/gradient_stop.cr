module UIng
  class Area < Control
    module Draw
      class Brush
        class GradientStop
          include BlockConstructor; block_constructor

          def initialize(pos : Number = 0.0,
                         r : Number = 0.0,
                         g : Number = 0.0,
                         b : Number = 0.0,
                         a : Number = 1.0)
            @cstruct = LibUI::DrawBrushGradientStop.new
            self.pos = pos
            self.r = r
            self.g = g
            self.b = b
            self.a = a
          end

          def pos : Float64
            @cstruct.pos
          end

          def pos=(value : Number)
            @cstruct.pos = NumericValue.unit_interval(value, "gradient stop position")
          end

          def r : Float64
            @cstruct.r
          end

          def r=(value : Number)
            @cstruct.r = NumericValue.unit_interval(value, "gradient stop red")
          end

          def g : Float64
            @cstruct.g
          end

          def g=(value : Number)
            @cstruct.g = NumericValue.unit_interval(value, "gradient stop green")
          end

          def b : Float64
            @cstruct.b
          end

          def b=(value : Number)
            @cstruct.b = NumericValue.unit_interval(value, "gradient stop blue")
          end

          def a : Float64
            @cstruct.a
          end

          def a=(value : Number)
            @cstruct.a = NumericValue.unit_interval(value, "gradient stop alpha")
          end

          def to_unsafe
            pointerof(@cstruct)
          end
        end
      end
    end
  end
end
