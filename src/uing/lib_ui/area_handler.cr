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
    #
    # NOTE:
    # - We intentionally DO NOT use @[Packed] here.
    # - This struct embeds AreaHandler as the first field so that a pointer to
    #   AreaHandlerExtended can be safely cast to AreaHandler* for C (libui).
    # - Crystal lib structs follow the C ABI (alignment/padding). There is no
    #   padding before the first field, so the base_handler will be correctly
    #   aligned at offset 0.
    # - Adding @[Packed] would reduce alignment to 1-byte and may yield an
    #   unaligned AreaHandler*, which can crash on some architectures (e.g. ARM).
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
