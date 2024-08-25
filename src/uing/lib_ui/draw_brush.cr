module UIng
  lib LibUI
    struct DrawBrush
      type : DrawBrushType
      r : LibC::Double
      g : LibC::Double
      b : LibC::Double
      a : LibC::Double
      x0 : LibC::Double
      y0 : LibC::Double
      x1 : LibC::Double
      y1 : LibC::Double
      outer_radius : LibC::Double
      stops : Pointer(DrawBrushGradientStop)
      num_stops : LibC::SizeT
    end
  end
end
