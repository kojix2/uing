module UIng
  class AreaMouseEvent
    def initialize
      @cstruct = LibUI::AreaMouseEvent.new
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
