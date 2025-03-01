require "../src/uing"

UIng.init

main_window = UIng::Window.new("Basic Area", 400, 400, 1)

handler = UIng::AreaHandler.new

handler.draw do |area_handler, area, area_draw_params|
  path = UIng::DrawPath.new(UIng::DrawFillMode::Winding)
  path.add_rectangle(0, 0, 400, 400)
  path.end(path)

  brush = UIng::DrawBrush.new
  brush.type = UIng::DrawBrushType::Solid
  brush.r = 0.4
  brush.g = 0.4
  brush.b = 0.8
  brush.a = 1.0

  # from pointer to struct
  ctx = area_draw_params.value.context
  UIng.draw_fill(ctx, path, brush)
  UIng.draw_free_path(path)
end

handler.mouse_event { |_, _, _| }
handler.mouse_crossed { |_, _, _| }
handler.drag_broken { |_, _| }
handler.key_event { |_, _, _| 0 }

area = UIng::Area.new(handler)

box = UIng::Box.new(:vertical)
box.set_padded(1)
box.append(area, 1)

main_window.set_child(box)
main_window.set_margined(1)

main_window.on_closing do
  UIng.quit
  1
end

main_window.show

UIng.main
UIng.uninit
