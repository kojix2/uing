module UIng
  class Area < Control
    module Draw
      class Brush
        class GradientStop
          def initialize(pos : Number = 0.0,
                         r : Number = 0.0,
                         g : Number = 0.0,
                         b : Number = 0.0,
                         a : Number = 1.0)
            @cstruct = LibUI::DrawBrushGradientStop.new
            self.pos = pos.to_f64
            self.r = r.to_f64
            self.g = g.to_f64
            self.b = b.to_f64
            self.a = a.to_f64
          end

          def pos : Float64
            @cstruct.pos
          end

          def pos=(value : Float64)
            @cstruct.pos = value
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

          def to_unsafe
            pointerof(@cstruct)
          end
        end
      end
    end
  end
end
