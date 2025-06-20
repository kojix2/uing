module UIng
  lib LibUI
    struct AreaKeyEvent
      key : LibC::Char
      ext_key : UIng::Area::ExtKey
      modifier : Modifiers
      modifiers : Modifiers
      up : LibC::Int
    end
  end
end
