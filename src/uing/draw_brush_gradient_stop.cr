module UIng
  class DrawBrushGradientStop
    def initialize(@cstruct : LibUI::DrawBrushGradientStop = LibUI::DrawBrushGradientStop.new)
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
