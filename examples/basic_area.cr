require "../src/uing"

UIng.init

main_window = UIng::Window.new("Basic Area", 400, 400)

handler = UIng::AreaHandler.new

handler.draw do |area, area_draw_params|
  UIng::DrawPath.new(UIng::DrawFillMode::Winding) do |path|
    path.add_rectangle(0, 0, 400, 400)
    path.end_ # `end` will also work, but it is a keyword in Crystal

    brush = UIng::DrawBrush.new
    brush.type = UIng::DrawBrushType::Solid
    brush.r = 0.4
    brush.g = 0.4
    brush.b = 0.8
    brush.a = 1.0

    # area_draw_params is now a wrapped AreaDrawParams object
    ctx = UIng::DrawContext.new(area_draw_params.context)
    ctx.fill(path, brush)
  end # Automatically releases the path
end

handler.mouse_event { |area, event| }
handler.mouse_crossed { |area, left| }
handler.drag_broken { |area| }
handler.key_event { |area, event| false }

area = UIng::Area.new(handler)

box = UIng::Box.new(:vertical)
box.padded = true
box.append(area, true)

main_window.child = box
main_window.margined = true

main_window.on_closing do
  UIng.quit
  true
end

main_window.show

UIng.main
UIng.uninit
