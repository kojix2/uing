module UIng
  class Area < Control
    module Draw
      class Brush
        class GradientStop
          def initialize
            @cstruct = LibUI::DrawBrushGradientStop.new
          end

          def pos : Float64
            @cstruct.pos
          end

          def pos=(value : Number)
            @cstruct.pos = value.to_f64
          end

          def r : Float64
            @cstruct.r
          end

          def r=(value : Number)
            @cstruct.r = value.to_f64
          end

          def g : Float64
            @cstruct.g
          end

          def g=(value : Number)
            @cstruct.g = value.to_f64
          end

          def b : Float64
            @cstruct.b
          end

          def b=(value : Number)
            @cstruct.b = value.to_f64
          end

          def a : Float64
            @cstruct.a
          end

          def a=(value : Number)
            @cstruct.a = value.to_f64
          end

          def to_unsafe
            pointerof(@cstruct)
          end
        end
      end
    end
  end
end
