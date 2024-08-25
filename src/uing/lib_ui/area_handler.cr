module UIng
  lib LibUI
    struct AreaHandler
      draw : (Pointer(AreaHandler), Pointer(Area), Pointer(AreaDrawParams) -> Void)
      mouse_event : (Pointer(AreaHandler), Pointer(Area), Pointer(AreaMouseEvent) -> Void)
      mouse_crossed : (Pointer(AreaHandler), Pointer(Area), LibC::Int -> Void)
      drag_broken : (Pointer(AreaHandler), Pointer(Area) -> Void)
      key_event : (Pointer(AreaHandler), Pointer(Area), Pointer(AreaKeyEvent) -> LibC::Int)
    end
  end
end
