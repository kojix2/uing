module UIng
  class DrawStrokeParams
    def initialize
      @cstruct = LibUI::DrawStrokeParams.new
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
