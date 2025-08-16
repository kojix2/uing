require "../src/uing"

UIng.init

handler = UIng::Area::Handler.new do
  draw { |area, params|
    brush = UIng::Area::Draw::Brush.new(:solid, 0.4, 0.4, 0.8, 1.0)
    params.context.fill_path(brush) do |path|
      path.add_rectangle(0, 0, 400, 400)
    end
  }

  mouse_event { |area, event|
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

  mouse_crossed { |area, left|
    puts "Mouse crossed: #{left}"
    nil
  }

  drag_broken { |area|
    puts "Drag broken"
    nil
  }

  key_event { |area, event|
    puts "Key event:"
    p! event.key
    p! event.ext_key
    p! event.modifier
    p! event.modifiers
    p! event.up
    false
  }
end

UIng::Window.new("Basic Area", 400, 400, margined: true) do
  set_child(
    UIng::Box.new(:vertical, padded: true) {
      append(
        UIng::Area.new(handler), stretchy: true
      )
    }
  )
  on_closing {
    UIng.quit
    true
  }
  show
end

UIng.main
UIng.uninit
