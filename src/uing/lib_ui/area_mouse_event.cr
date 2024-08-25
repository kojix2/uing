module UIng
  lib LibUI
    struct AreaMouseEvent
      x : LibC::Double
      y : LibC::Double
      area_width : LibC::Double
      area_height : LibC::Double
      down : LibC::Int
      up : LibC::Int
      count : LibC::Int
      modifiers : Modifiers
      held1_to64 : UInt64
    end
  end
end
