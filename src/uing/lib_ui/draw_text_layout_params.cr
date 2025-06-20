module UIng
  lib LibUI
    struct DrawTextLayoutParams
      string : Pointer(AttributedString)
      default_font : Pointer(FontDescriptor)
      width : LibC::Double
      align : UIng::Area::Draw::TextAlign
    end
  end
end
