require "../../src/uing"

UIng.init

# Drawing tools example
# Demonstrates: Mouse dragging, line drawing, paint-like functionality

# Drawing state
drawing = false
current_path = [] of {x: Float64, y: Float64}
completed_paths = [] of Array({x: Float64, y: Float64})
current_brush_size = 3.0
current_color = {r: 0.2, g: 0.2, b: 0.8}

handler = UIng::Area::Handler.new do
  draw { |area, params|
    ctx = params.context

    # Draw white background
    bg_brush = UIng::Area::Draw::Brush.new(:solid, 1.0, 1.0, 1.0, 1.0)
    ctx.fill_path(bg_brush) do |path|
      path.add_rectangle(0, 0, 600, 400)
    end

    # Draw toolbar background
    toolbar_brush = UIng::Area::Draw::Brush.new(:solid, 0.9, 0.9, 0.9, 1.0)
    ctx.fill_path(toolbar_brush) do |path|
      path.add_rectangle(0, 0, 600, 50)
    end

    # Draw toolbar border
    border_brush = UIng::Area::Draw::Brush.new(:solid, 0.7, 0.7, 0.7, 1.0)
    stroke_params = UIng::Area::Draw::StrokeParams.new(
      cap: :flat,
      join: :miter,
      thickness: 1.0,
      miter_limit: 10.0
    )
    ctx.stroke_path(border_brush, stroke_params) do |path|
      path.add_rectangle(0, 50, 600, 1)
    end

    # Draw color palette
    colors = [
      {r: 0.0, g: 0.0, b: 0.0}, # Black
      {r: 0.8, g: 0.2, b: 0.2}, # Red
      {r: 0.2, g: 0.8, b: 0.2}, # Green
      {r: 0.2, g: 0.2, b: 0.8}, # Blue
      {r: 0.8, g: 0.8, b: 0.2}, # Yellow
      {r: 0.8, g: 0.2, b: 0.8}, # Magenta
      {r: 0.2, g: 0.8, b: 0.8}, # Cyan
    ]

    colors.each_with_index do |color, i|
      color_brush = UIng::Area::Draw::Brush.new(:solid, color[:r], color[:g], color[:b], 1.0)
      ctx.fill_path(color_brush) do |path|
        path.add_rectangle(10 + i * 25, 10, 20, 20)
      end

      # Highlight current color
      if current_color == color
        highlight_brush = UIng::Area::Draw::Brush.new(:solid, 1.0, 1.0, 1.0, 1.0)
        thick_stroke = UIng::Area::Draw::StrokeParams.new(
          cap: :flat,
          join: :miter,
          thickness: 2.0,
          miter_limit: 10.0
        )
        ctx.stroke_path(highlight_brush, thick_stroke) do |path|
          path.add_rectangle(10 + i * 25, 10, 20, 20)
        end
      end
    end

    # Draw brush size indicators
    [1.0, 3.0, 6.0, 10.0].each_with_index do |size, i|
      indicator_brush = UIng::Area::Draw::Brush.new(:solid, 0.3, 0.3, 0.3, 1.0)
      ctx.fill_path(indicator_brush) do |path|
        path.new_figure_with_arc(220 + i * 30, 25, size / 2, 0, Math::PI * 2, false)
      end

      # Highlight current brush size
      if current_brush_size == size
        highlight_brush = UIng::Area::Draw::Brush.new(:solid, 0.8, 0.8, 0.2, 1.0)
        highlight_stroke = UIng::Area::Draw::StrokeParams.new(
          cap: :round,
          join: :round,
          thickness: 2.0,
          miter_limit: 10.0
        )
        ctx.stroke_path(highlight_brush, highlight_stroke) do |path|
          path.new_figure_with_arc(220 + i * 30, 25, size / 2 + 3, 0, Math::PI * 2, false)
        end
      end
    end

    # Draw all completed paths
    path_brush = UIng::Area::Draw::Brush.new(:solid, current_color[:r], current_color[:g], current_color[:b], 1.0)
    path_stroke = UIng::Area::Draw::StrokeParams.new(
      cap: :round,
      join: :round,
      thickness: current_brush_size,
      miter_limit: 10.0
    )

    completed_paths.each do |path_points|
      next if path_points.size < 2

      ctx.stroke_path(path_brush, path_stroke) do |path|
        first_point = path_points.first
        path.new_figure(first_point[:x], first_point[:y])

        path_points[1..].each do |point|
          path.line_to(point[:x], point[:y])
        end
      end
    end

    # Draw current path being drawn
    if current_path.size >= 2
      ctx.stroke_path(path_brush, path_stroke) do |path|
        first_point = current_path.first
        path.new_figure(first_point[:x], first_point[:y])

        current_path[1..].each do |point|
          path.line_to(point[:x], point[:y])
        end
      end
    end
  }

  mouse_event { |area, event|
    # Handle toolbar clicks
    if event.y <= 50
      if event.down == 1 # Left click in toolbar
        # Color palette clicks
        if event.y >= 10 && event.y <= 30
          color_index = ((event.x - 10) / 25).to_i
          colors = [
            {r: 0.0, g: 0.0, b: 0.0}, # Black
            {r: 0.8, g: 0.2, b: 0.2}, # Red
            {r: 0.2, g: 0.8, b: 0.2}, # Green
            {r: 0.2, g: 0.2, b: 0.8}, # Blue
            {r: 0.8, g: 0.8, b: 0.2}, # Yellow
            {r: 0.8, g: 0.2, b: 0.8}, # Magenta
            {r: 0.2, g: 0.8, b: 0.8}, # Cyan
          ]
          if color_index >= 0 && color_index < colors.size
            current_color = colors[color_index]
          end
        end

        # Brush size clicks
        if event.x >= 220 && event.x <= 340
          size_index = ((event.x - 220) / 30).to_i
          sizes = [1.0, 3.0, 6.0, 10.0]
          if size_index >= 0 && size_index < sizes.size
            current_brush_size = sizes[size_index]
          end
        end

        # Clear button (right side of toolbar)
        if event.x >= 500
          completed_paths.clear
          current_path.clear
        end

        area.queue_redraw_all
      end
      next
    end

    # Handle drawing area
    if event.down == 1 # Left mouse button pressed
      drawing = true
      current_path.clear
      current_path << {x: event.x, y: event.y}
    elsif event.up == 1 # Left mouse button released
      if drawing && current_path.size > 0
        completed_paths << current_path.dup
        current_path.clear
        drawing = false
      end
    elsif drawing && event.held1_to64 == 1 # Dragging with left button
      current_path << {x: event.x, y: event.y}

      # Limit path length to prevent memory issues
      if current_path.size > 1000
        current_path.shift
      end
    end

    area.queue_redraw_all
  }

  key_event { |area, event|
    if event.up == 0 # Key pressed
      case event.key
      when 'c'.ord, 'C'.ord
        completed_paths.clear
        current_path.clear
        area.queue_redraw_all
      end
    end
    true
  }
end

window = UIng::Window.new("Area - Drawing Tools", 600, 400)
window.on_closing do
  UIng.quit
  true
end

# Create info label
info_label = UIng::Label.new("Click colors and brush sizes in toolbar. Drag to draw. Right side of toolbar = Clear. C = Clear all")

area = UIng::Area.new(handler)
box = UIng::Box.new(:vertical, padded: true)
box.append(info_label, stretchy: false)
box.append(area, stretchy: true)
window.child = box

window.show

UIng.main
UIng.uninit
