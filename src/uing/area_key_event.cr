module UIng
  class AreaKeyEvent
    def initialize(@cstruct : LibUI::AreaKeyEvent = LibUI::AreaKeyEvent.new)
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
