module UIng
  class Area < Control
    module Draw
      class Brush
        class GradientStop
          def initialize(@cstruct : LibUI::DrawBrushGradientStop = LibUI::DrawBrushGradientStop.new)
          end

          forward_missing_to(@cstruct)

          def to_unsafe
            pointerof(@cstruct)
          end
        end
      end
    end
  end
end
