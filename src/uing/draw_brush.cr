module UIng
  class DrawBrush
    def initialize(@cstruct : LibUI::DrawBrush = LibUI::DrawBrush.new)
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
