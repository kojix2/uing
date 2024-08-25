require "../src/uing"

UIng.init

handler = UIng::AreaHandler.new
area = UIng.new_area(handler)

handler_draw_event = ->(v1 : Void*, v2 : Void*, adp : Void*) {
  area_draw_params = UIng::AreaDrawParams.new
  area_draw_params.context = adp
  default_font = UIng::FontDescriptor.new
  default_font.family = "Georgia"
  default_font.size = 14
  default_font.weight = UIng::LibUI::TextWeight::Normal   # FIXME
  default_font.italic = UIng::LibUI::TextItalic::Normal   # FIXME
  default_font.stretch = UIng::LibUI::TextStretch::Normal # FIXME

  params = UIng::DrawTextLayoutParams.new
  params.string = astr = UIng.new_attributed_string("たぬき")
  params.default_font = default_font
  params.width = area_draw_params.area_width
  params.align = UIng::LibUI::DrawTextAlign::Left # FIXME

  text_layout = UIng.draw_new_text_layout(params)
  UIng.draw_text(area_draw_params.context, text_layout, 0, 0)
  UIng.draw_free_text_layout(text_layout)
}

handler.draw = handler_draw_event

# These are to prevent the function pointers from being garbage collected.
handler.mouse_event = ->(v1 : Void*, v2 : Void*, v3 : Void*) { }
handler.mouse_crossed = ->(v1 : Void*, v2 : Void*, v3 : LibC::Int) { }
handler.drag_broken = ->(v1 : Void*, v2 : Void*) { }
handler.key_event = ->(v1 : Void*, v2 : Void*, v3 : Void*) { 0 }

box = UIng.new_vertical_box
UIng.box_set_padded(box, 1)
UIng.box_append(box, area, 1)

main_window = UIng.new_window("tanu", 600, 400, 1)
UIng.window_set_margined(main_window, 1)
UIng.window_set_child(main_window, box)

UIng.window_on_closing(main_window) do
  UIng.quit
  1
end
UIng.control_show(main_window)

UIng.main
UIng.uninit
