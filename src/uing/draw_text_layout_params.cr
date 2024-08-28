module UIng
  class DrawTextLayoutParams
    def initialize(@cstruct : LibUI::DrawTextLayoutParams = LibUI::DrawTextLayoutParams.new)
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
