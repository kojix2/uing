require "../../src/uing"

UIng.init

# Mouse interaction example
# Demonstrates: Mouse event handling, click detection, coordinate tracking

# Store clicked points
clicked_points = [] of {x: Float64, y: Float64, color: {r: Float64, g: Float64, b: Float64}}

handler = UIng::Area::Handler.new do
  draw { |area, params|
    ctx = params.context

    # Draw background
    bg_brush = UIng::Area::Draw::Brush.new(:solid, 0.95, 0.95, 0.95, 1.0)
    ctx.fill_path(bg_brush) do |path|
      path.add_rectangle(0, 0, 400, 300)
    end

    # Draw instruction text area (simulated)
    text_bg_brush = UIng::Area::Draw::Brush.new(:solid, 0.9, 0.9, 1.0, 1.0)
    ctx.fill_path(text_bg_brush) do |path|
      path.add_rectangle(10, 10, 380, 40)
    end

    # Draw border for instruction area
    border_brush = UIng::Area::Draw::Brush.new(:solid, 0.5, 0.5, 0.5, 1.0)
    stroke_params = UIng::Area::Draw::StrokeParams.new(
      cap: :flat,
      join: :miter,
      thickness: 1.0,
      miter_limit: 10.0
    )
    ctx.stroke_path(border_brush, stroke_params) do |path|
      path.add_rectangle(10, 10, 380, 40)
    end

    # Draw all clicked points as circles
    clicked_points.each do |point|
      brush = UIng::Area::Draw::Brush.new(:solid, point[:color][:r], point[:color][:g], point[:color][:b], 0.8)
      ctx.fill_path(brush) do |path|
        path.new_figure_with_arc(point[:x], point[:y], 8, 0, Math::PI * 2, false)
      end

      # Draw a small white border around each circle
      white_brush = UIng::Area::Draw::Brush.new(:solid, 1.0, 1.0, 1.0, 1.0)
      thin_stroke = UIng::Area::Draw::StrokeParams.new(
        cap: :round,
        join: :round,
        thickness: 1.5,
        miter_limit: 10.0
      )
      ctx.stroke_path(white_brush, thin_stroke) do |path|
        path.new_figure_with_arc(point[:x], point[:y], 8, 0, Math::PI * 2, false)
      end
    end
  }

  mouse_event { |area, event|
    # Only respond to left mouse button clicks (down event)
    if event.down == 1
      # Generate a random color for this click
      color = {
        r: rand * 0.8 + 0.2, # Avoid too dark colors
        g: rand * 0.8 + 0.2,
        b: rand * 0.8 + 0.2,
      }

      # Add the clicked point
      clicked_points << {x: event.x, y: event.y, color: color}

      # Limit the number of points to prevent memory issues
      if clicked_points.size > 50
        clicked_points.shift
      end

      # Trigger a redraw
      area.queue_redraw_all
    elsif event.down == 2 # Right mouse button - clear all points
      clicked_points.clear
      area.queue_redraw_all
    end
  }

  mouse_crossed { |area, left|
  # Optional: Could show/hide cursor or change appearance
  }

  drag_broken { |area|
  # Handle drag operations if needed
  }

  key_event { |area, event|
    # Handle key events - 'c' or 'C' to clear
    if event.up == 0 # Key pressed (not released)
      case event.key
      when 'c'.ord, 'C'.ord
        clicked_points.clear
        area.queue_redraw_all
      end
    end
    true
  }
end

window = UIng::Window.new("Area - Mouse Interaction", 400, 300)
window.on_closing do
  UIng.quit
  true
end

# Create info label
info_label = UIng::Label.new("Left Click: Add colored circle | Right Click: Clear all | C: Clear")

area = UIng::Area.new(handler)
box = UIng::Box.new(:vertical, padded: true)
box.append(info_label, stretchy: false)
box.append(area, stretchy: true)
window.child = box

window.show

UIng.main
UIng.uninit
