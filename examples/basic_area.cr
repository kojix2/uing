require "../src/uing"

UIng.init

main_window = UIng.new_window("Basic Area", 400, 400, 1)

handler = UIng::AreaHandler.new

handler_draw_event = ->(area_handler : UIng::LibUI::AreaHandler*, area : UIng::LibUI::Area*, area_draw_params : UIng::LibUI::AreaDrawParams*) {
  path = UIng.draw_new_path(UIng::LibUI::DrawFillMode::Winding)
  UIng.draw_path_add_rectangle(path, 0, 0, 400, 400)
  UIng.draw_path_end(path)

  brush = UIng::DrawBrush.new
  brush.type = UIng::LibUI::DrawBrushType::Solid
  brush.r = 0.4
  brush.g = 0.4
  brush.b = 0.8
  brush.a = 1.0

  # from pointer to struct
  ctx = area_draw_params.value.context
  UIng.draw_fill(ctx, path, brush)
  UIng.draw_free_path(path)
}

handler.draw = handler_draw_event
handler.mouse_event = ->(area_handler : UIng::LibUI::AreaHandler*, area : UIng::LibUI::Area*, event : UIng::LibUI::AreaMouseEvent*) { }
handler.mouse_crossed = ->(area_handler : UIng::LibUI::AreaHandler*, area : UIng::LibUI::Area*, left : Int32) { }
handler.drag_broken = ->(area_handler : UIng::LibUI::AreaHandler*, area : UIng::LibUI::Area*) { }
handler.key_event = ->(area_handler : UIng::LibUI::AreaHandler*, area : UIng::LibUI::Area*, key_event : UIng::LibUI::AreaKeyEvent*) { 0 }

area = UIng.new_area(handler)

box = UIng.new_vertical_box
UIng.box_set_padded(box, 1)
UIng.box_append(box, area, 1)

UIng.window_set_child(main_window, box)
UIng.window_set_margined(main_window, 1)

UIng.window_on_closing(main_window) do
  UIng.quit
  1
end

UIng.control_show(main_window)

UIng.main
UIng.uninit
