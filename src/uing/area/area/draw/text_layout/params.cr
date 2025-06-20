module UIng
  class Area < Control
    module Draw
      class TextLayout
        class Params
          def initialize(@cstruct : LibUI::DrawTextLayoutParams = LibUI::DrawTextLayoutParams.new)
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
