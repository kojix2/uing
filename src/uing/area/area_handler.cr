module UIng
  class AreaHandler
    include BlockConstructor; block_constructor

    # Store callback blocks to prevent GC collection
    @draw_block : Proc(LibUI::AreaHandler*, LibUI::Area*, LibUI::AreaDrawParams*, Void)?
    @mouse_event_block : Proc(LibUI::AreaHandler*, LibUI::Area*, LibUI::AreaMouseEvent*, Void)?
    @mouse_crossed_block : Proc(LibUI::AreaHandler*, LibUI::Area*, LibC::Int, Void)?
    @drag_broken_block : Proc(LibUI::AreaHandler*, LibUI::Area*, Void)?
    @key_event_block : Proc(LibUI::AreaHandler*, LibUI::Area*, LibUI::AreaKeyEvent*, LibC::Int)?

    def initialize(@cstruct : LibUI::AreaHandler = LibUI::AreaHandler.new)
    end

    def draw(&block : (LibUI::AreaHandler*, LibUI::Area*, LibUI::AreaDrawParams*) -> Void)
      @draw_block = block   # Store reference to prevent GC
      @cstruct.draw = block # Crystal automatically checks safety
    end

    def mouse_event(&block : (LibUI::AreaHandler*, LibUI::Area*, LibUI::AreaMouseEvent*) -> Void)
      @mouse_event_block = block   # Store reference to prevent GC
      @cstruct.mouse_event = block # Crystal automatically checks safety
    end

    def mouse_crossed(&block : (LibUI::AreaHandler*, LibUI::Area*, LibC::Int) -> Void)
      @mouse_crossed_block = block   # Store reference to prevent GC
      @cstruct.mouse_crossed = block # Crystal automatically checks safety
    end

    def drag_broken(&block : (LibUI::AreaHandler*, LibUI::Area*) -> Void)
      @drag_broken_block = block   # Store reference to prevent GC
      @cstruct.drag_broken = block # Crystal automatically checks safety
    end

    def key_event(&block : (LibUI::AreaHandler*, LibUI::Area*, LibUI::AreaKeyEvent*) -> LibC::Int)
      @key_event_block = block   # Store reference to prevent GC
      @cstruct.key_event = block # Crystal automatically checks safety
    end

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
