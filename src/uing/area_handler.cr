module UIng
  class AreaHandler
    def initialize(@cstruct : LibUI::AreaHandler = LibUI::AreaHandler.new)
    end

    forward_missing_to(@cstruct)

    def draw(&block : (LibUI::AreaHandler*, LibUI::Area*, LibUI::AreaDrawParams*) -> Void)
      @cstruct.draw = block
    end

    def mouse_event(&block : (LibUI::AreaHandler*, LibUI::Area*, LibUI::AreaMouseEvent*) -> Void)
      @cstruct.mouse_event = block
    end

    def mouse_crossed(&block : (LibUI::AreaHandler*, LibUI::Area*, LibC::Int) -> Void)
      @cstruct.mouse_crossed = block
    end

    def drag_broken(&block : (LibUI::AreaHandler*, LibUI::Area*) -> Void)
      @cstruct.drag_broken = block
    end

    def key_event(&block : (LibUI::AreaHandler*, LibUI::Area*, LibUI::AreaKeyEvent*) -> LibC::Int)
      @cstruct.key_event = block
    end

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
