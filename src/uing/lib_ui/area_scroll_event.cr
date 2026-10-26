module UIng
  lib LibUI
    struct AreaScrollEvent
      x : LibC::Double
      y : LibC::Double
      delta_x : LibC::Double
      delta_y : LibC::Double
      modifiers : UIng::Modifiers
    end
  end
end
