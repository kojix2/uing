module UIng
  lib LibUI
    struct AreaKeyEvent
      key : LibC::Char
      ext_key : UIng::ExtKey
      modifier : UIng::Modifiers
      modifiers : UIng::Modifiers
      up : LibC::Int
    end
  end
end
