module UIng
  lib LibUI
    struct AreaDrawParams
      context : Pointer(DrawContext)
      area_width : LibC::Double
      area_height : LibC::Double
      clip_x : LibC::Double
      clip_y : LibC::Double
      clip_width : LibC::Double
      clip_height : LibC::Double
    end
  end
end
