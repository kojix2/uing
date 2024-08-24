module UIng
  class DrawMatrix
    def initialize
      @cstruct = LibUI::DrawMatrix.new
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
