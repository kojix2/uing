module UIng
  class Area < Control
    module Draw
      class StrokeParams
        def initialize(@cstruct : LibUI::DrawStrokeParams = LibUI::DrawStrokeParams.new)
        end

        forward_missing_to(@cstruct)

        def to_unsafe
          pointerof(@cstruct)
        end
      end
    end
  end
end
