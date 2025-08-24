require "../../src/uing"

UIng.init

# Scrolling area example
# Demonstrates: Scrolling area with large content, viewport management

# Large canvas size (bigger than window)
CANVAS_WIDTH  = 1200.0
CANVAS_HEIGHT =  800.0

# Grid properties
GRID_SIZE       =  50.0
MAJOR_GRID_SIZE = 200.0

handler = UIng::Area::Handler.new do
  draw { |area, params|
    ctx = params.context

    # Draw white background for the entire canvas
    bg_brush = UIng::Area::Draw::Brush.new(:solid, 1.0, 1.0, 1.0, 1.0)
    ctx.fill_path(bg_brush) do |path|
      path.add_rectangle(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
    end

    # Draw minor grid lines
    minor_grid_brush = UIng::Area::Draw::Brush.new(:solid, 0.9, 0.9, 0.9, 1.0)
    minor_stroke = UIng::Area::Draw::StrokeParams.new(
      cap: :flat,
      join: :miter,
      thickness: 0.5,
      miter_limit: 10.0
    )

    # Vertical minor grid lines
    x = 0.0
    while x <= CANVAS_WIDTH
      ctx.stroke_path(minor_grid_brush, minor_stroke) do |path|
        path.new_figure(x, 0)
        path.line_to(x, CANVAS_HEIGHT)
      end
      x += GRID_SIZE
    end

    # Horizontal minor grid lines
    y = 0.0
    while y <= CANVAS_HEIGHT
      ctx.stroke_path(minor_grid_brush, minor_stroke) do |path|
        path.new_figure(0, y)
        path.line_to(CANVAS_WIDTH, y)
      end
      y += GRID_SIZE
    end

    # Draw major grid lines
    major_grid_brush = UIng::Area::Draw::Brush.new(:solid, 0.7, 0.7, 0.7, 1.0)
    major_stroke = UIng::Area::Draw::StrokeParams.new(
      cap: :flat,
      join: :miter,
      thickness: 1.0,
      miter_limit: 10.0
    )

    # Vertical major grid lines
    x = 0.0
    while x <= CANVAS_WIDTH
      ctx.stroke_path(major_grid_brush, major_stroke) do |path|
        path.new_figure(x, 0)
        path.line_to(x, CANVAS_HEIGHT)
      end
      x += MAJOR_GRID_SIZE
    end

    # Horizontal major grid lines
    y = 0.0
    while y <= CANVAS_HEIGHT
      ctx.stroke_path(major_grid_brush, major_stroke) do |path|
        path.new_figure(0, y)
        path.line_to(CANVAS_WIDTH, y)
      end
      y += MAJOR_GRID_SIZE
    end

    # Draw some sample content at different positions
    content_brush = UIng::Area::Draw::Brush.new(:solid, 0.2, 0.4, 0.8, 0.8)

    # Draw rectangles at various positions
    positions = [
      {x: 100.0, y: 100.0},
      {x: 300.0, y: 200.0},
      {x: 500.0, y: 150.0},
      {x: 700.0, y: 300.0},
      {x: 900.0, y: 250.0},
      {x: 200.0, y: 400.0},
      {x: 600.0, y: 500.0},
      {x: 1000.0, y: 600.0},
    ]

    positions.each do |pos|
      ctx.fill_path(content_brush) do |path|
        path.add_rectangle(pos[:x], pos[:y], 80, 60)
      end
    end

    # Draw circles at various positions
    circle_brush = UIng::Area::Draw::Brush.new(:solid, 0.8, 0.2, 0.2, 0.8)
    circle_positions = [
      {x: 150.0, y: 250.0},
      {x: 450.0, y: 350.0},
      {x: 750.0, y: 450.0},
      {x: 350.0, y: 550.0},
      {x: 850.0, y: 150.0},
      {x: 1050.0, y: 400.0},
    ]

    circle_positions.each do |pos|
      ctx.fill_path(circle_brush) do |path|
        path.new_figure_with_arc(pos[:x], pos[:y], 30, 0, Math::PI * 2, false)
      end
    end

    # Draw coordinate labels at major grid intersections
    default_font = UIng::FontDescriptor.new(
      family: "Arial",
      size: 10,
      weight: :normal,
      italic: :normal,
      stretch: :normal
    )

    label_brush = UIng::Area::Draw::Brush.new(:solid, 0.5, 0.5, 0.5, 1.0)

    # Only draw labels at major grid intersections to avoid clutter
    x = 0.0
    while x <= CANVAS_WIDTH
      y = 0.0
      while y <= CANVAS_HEIGHT
        if x.to_i % MAJOR_GRID_SIZE.to_i == 0 && y.to_i % MAJOR_GRID_SIZE.to_i == 0
          coord_text = UIng::Area::AttributedString.new("(#{x.to_i},#{y.to_i})")
          UIng::Area::Draw::TextLayout.open(
            string: coord_text,
            default_font: default_font,
            width: 100,
            align: UIng::Area::Draw::TextAlign::Left
          ) do |text_layout|
            ctx.draw_text_layout(text_layout, x + 5, y + 5)
          end
          coord_text.free
        end
        y += MAJOR_GRID_SIZE
      end
      x += MAJOR_GRID_SIZE
    end

    # Draw border around the entire canvas
    border_brush = UIng::Area::Draw::Brush.new(:solid, 0.0, 0.0, 0.0, 1.0)
    border_stroke = UIng::Area::Draw::StrokeParams.new(
      cap: :flat,
      join: :miter,
      thickness: 2.0,
      miter_limit: 10.0
    )
    ctx.stroke_path(border_brush, border_stroke) do |path|
      path.add_rectangle(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
    end
  }

  mouse_event { |area, event|
    # Optional: Could add functionality like clicking to scroll to a position
    if event.down == 1
      # Example: scroll to clicked position (center it in view)
      area.scroll_to(event.x - 200, event.y - 150, 400, 300)
    end
  }

  key_event { |area, event|
    if event.up == 0 # Key pressed
      case event.key
      when 'h'.ord, 'H'.ord # Home - scroll to top-left
        area.scroll_to(0, 0, 400, 300)
      when 'e'.ord, 'E'.ord # End - scroll to bottom-right
        area.scroll_to(CANVAS_WIDTH - 400, CANVAS_HEIGHT - 300, 400, 300)
      when 'c'.ord, 'C'.ord # Center - scroll to center
        area.scroll_to(CANVAS_WIDTH / 2 - 200, CANVAS_HEIGHT / 2 - 150, 400, 300)
      end
    end
    true
  }
end

# Create scrolling area with specified canvas size
area = UIng::Area.new(handler, CANVAS_WIDTH.to_i, CANVAS_HEIGHT.to_i)

window = UIng::Window.new("Area - Scrolling Area", 600, 450)
window.on_closing do
  UIng.quit
  true
end

# Create info labels
info_label1 = UIng::Label.new("This is a scrolling area with content larger than the visible area.")
info_label2 = UIng::Label.new("Click to scroll to position. H=Home, C=Center, E=End")

box = UIng::Box.new(:vertical, padded: true)
box.append(info_label1, stretchy: false)
box.append(info_label2, stretchy: false)
box.append(area, stretchy: true)
window.child = box

window.show

UIng.main
UIng.uninit
