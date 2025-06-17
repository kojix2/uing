require "../src/uing"

UIng.init

main_window = UIng::Window.new("Basic Area", 400, 400)

handler = UIng::Area::Handler.new

handler.draw do |area, area_draw_params|
  UIng::DrawPath.new(:winding) do |path|
    path.add_rectangle(0, 0, 400, 400)
    path.end_ # `end` will also work, but it is a keyword in Crystal

    brush = UIng::DrawBrush.new
    brush.type = UIng::DrawBrushType::Solid
    brush.r = 0.4
    brush.g = 0.4
    brush.b = 0.8
    brush.a = 1.0

    # area_draw_params is now a wrapped Area::DrawParams object
    ctx = area_draw_params.context
    ctx.fill(path, brush)
  end # Automatically releases the path
end

handler.mouse_event { |area, event|
  puts "Mouse event:"
  p! event.x
  p! event.y
  p! event.area_width
  p! event.area_height
  p! event.down
  p! event.up
  p! event.count
  p! event.modifiers
  p! event.held1_to64
  nil
}

handler.mouse_crossed { |area, left|
  puts "Mouse crossed: #{left}"
  nil
}
handler.drag_broken { |area|
  puts "Drag broken"
  nil
}
handler.key_event { |area, event|
  puts "Key event:"
  p! event.key
  p! event.ext_key
  p! event.modifier
  p! event.modifiers
  p! event.up
  false
}

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
