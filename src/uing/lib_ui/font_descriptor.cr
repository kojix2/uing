module UIng
  lib LibUI
    struct FontDescriptor
      family : Pointer(LibC::Char)
      size : LibC::Double
      weight : TextWeight
      italic : TextItalic
      stretch : TextStretch
    end
  end
end
