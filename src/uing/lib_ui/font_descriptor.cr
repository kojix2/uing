module UIng
  lib LibUI
    # Use UIng.free_font_descriptor to free the LibC::Char memory.
    # Use UIng.free_font_button_font to free the memory if the font is from a font button.
    struct FontDescriptor
      family : Pointer(LibC::Char)
      size : LibC::Double
      weight : TextWeight
      italic : TextItalic
      stretch : TextStretch
    end
  end
end
