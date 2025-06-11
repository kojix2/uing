module UIng
  lib LibUI
    struct AreaHandler
      draw : (Pointer(AreaHandler), Pointer(Area), Pointer(AreaDrawParams) -> Void)
      mouse_event : (Pointer(AreaHandler), Pointer(Area), Pointer(AreaMouseEvent) -> Void)
      mouse_crossed : (Pointer(AreaHandler), Pointer(Area), LibC::Int -> Void)
      drag_broken : (Pointer(AreaHandler), Pointer(Area) -> Void)
      key_event : (Pointer(AreaHandler), Pointer(Area), Pointer(AreaKeyEvent) -> LibC::Int)
    end

    # Extended handler structure that contains the base AreaHandler
    # and individual boxes for each callback
    @[Packed]
    struct AreaHandlerExtended
      base_handler : AreaHandler
      draw_box : Pointer(Void)
      mouse_event_box : Pointer(Void)
      mouse_crossed_box : Pointer(Void)
      drag_broken_box : Pointer(Void)
      key_event_box : Pointer(Void)
    end
  end
end
