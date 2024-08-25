module UIng
  lib LibUI
    struct DrawTextLayoutParams
      string : Pointer(AttributedString)
      default_font : Pointer(FontDescriptor)
      width : LibC::Double
      align : DrawTextAlign
    end
  end
end
