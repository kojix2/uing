require "../src/uing"

UIng.init

handler = UIng::Area::Handler.new do
  draw do |_area, params|
    brush = UIng::Area::Draw::Brush.new(:solid, 0.4, 0.4, 0.8, 1.0)
    params.context.fill_path(brush) do |path|
      path.add_rectangle(0, 0, 400, 400)
    end
  end

  mouse_event do |_area, event|
    puts "Mouse event:"
    puts "x: #{event.x}"
    puts "y: #{event.y}"
    puts "area_width: #{event.area_width}"
    puts "area_height: #{event.area_height}"
    puts "down: #{event.down}"
    puts "up: #{event.up}"
    puts "count: #{event.count}"
    puts "modifiers: #{event.modifiers}"
    puts "held1_to64: #{event.held1_to64}"
    nil
  end

  mouse_crossed do |_area, left|
    puts "Mouse crossed: #{left}"
    nil
  end

  drag_broken do |_area|
    puts "Drag broken"
    nil
  end

  key_event do |_area, event|
    puts "Key event:"
    puts "key: #{event.key}"
    puts "ext_key: #{event.ext_key}"
    puts "modifier: #{event.modifier}"
    puts "modifiers: #{event.modifiers}"
    puts "up: #{event.up}"
    false
  end
end

UIng::Window.new("Basic Area", 400, 400, margined: true) do
  set_child(
    UIng::Box.new(:vertical, padded: true) do
      append(
        UIng::Area.new(handler), stretchy: true
      )
    end
  )
  on_closing do
    UIng.quit
    true
  end
  show
end

UIng.main
UIng.uninit
