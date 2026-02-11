module UIng
  lib LibUI
    struct AreaKeyEvent
      key : LibC::Char
      ext_key : UIng::Area::ExtKey
      modifier : UIng::Area::Modifiers
      modifiers : UIng::Area::Modifiers
      up : LibC::Int
    end
  end
end
