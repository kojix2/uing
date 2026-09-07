module UIng
  lib LibUI
    # Use LibUI.free_font_descriptor for any descriptor filled by libui-ng.
    struct FontDescriptor
      family : Pointer(LibC::Char)
      size : LibC::Double
      weight : TextWeight
      italic : TextItalic
      stretch : TextStretch
    end
  end
end
