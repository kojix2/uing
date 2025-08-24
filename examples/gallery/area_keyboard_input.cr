require "../../src/uing"

UIng.init

# Keyboard input example
# Demonstrates: Key event handling, modifier keys, key codes

# Application state
current_shape = :rectangle
current_color = {r: 0.2, g: 0.4, b: 0.8}
shapes = [] of {type: Symbol, x: Float64, y: Float64, color: {r: Float64, g: Float64, b: Float64}}
last_key_info = "Press keys to see info here"

handler = UIng::Area::Handler.new do
  draw { |area, params|
    ctx = params.context

    # Draw background
    bg_brush = UIng::Area::Draw::Brush.new(:solid, 0.95, 0.95, 0.95, 1.0)
    ctx.fill_path(bg_brush) do |path|
      path.add_rectangle(0, 0, 500, 400)
    end

    # Draw info panel
    info_bg_brush = UIng::Area::Draw::Brush.new(:solid, 0.9, 0.9, 1.0, 1.0)
    ctx.fill_path(info_bg_brush) do |path|
      path.add_rectangle(10, 10, 480, 80)
    end

    # Draw border for info panel
    border_brush = UIng::Area::Draw::Brush.new(:solid, 0.5, 0.5, 0.5, 1.0)
    stroke_params = UIng::Area::Draw::StrokeParams.new(
      cap: :flat,
      join: :miter,
      thickness: 1.0,
      miter_limit: 10.0
    )
    ctx.stroke_path(border_brush, stroke_params) do |path|
      path.add_rectangle(10, 10, 480, 80)
    end

    # Draw current shape indicator
    indicator_brush = UIng::Area::Draw::Brush.new(:solid, current_color[:r], current_color[:g], current_color[:b], 1.0)
    case current_shape
    when :rectangle
      ctx.fill_path(indicator_brush) do |path|
        path.add_rectangle(20, 20, 30, 20)
      end
    when :circle
      ctx.fill_path(indicator_brush) do |path|
        path.new_figure_with_arc(35, 30, 15, 0, Math::PI * 2, false)
      end
    when :triangle
      ctx.fill_path(indicator_brush) do |path|
        path.new_figure(35, 20)
        path.line_to(50, 40)
        path.line_to(20, 40)
        path.close_figure
      end
    end

    # Draw all shapes
    shapes.each do |shape|
      shape_brush = UIng::Area::Draw::Brush.new(:solid, shape[:color][:r], shape[:color][:g], shape[:color][:b], 0.8)
      case shape[:type]
      when :rectangle
        ctx.fill_path(shape_brush) do |path|
          path.add_rectangle(shape[:x] - 15, shape[:y] - 10, 30, 20)
        end
      when :circle
        ctx.fill_path(shape_brush) do |path|
          path.new_figure_with_arc(shape[:x], shape[:y], 12, 0, Math::PI * 2, false)
        end
      when :triangle
        ctx.fill_path(shape_brush) do |path|
          path.new_figure(shape[:x], shape[:y] - 12)
          path.line_to(shape[:x] + 12, shape[:y] + 8)
          path.line_to(shape[:x] - 12, shape[:y] + 8)
          path.close_figure
        end
      end
    end
  }

  mouse_event { |area, event|
    # Add shape at mouse click position
    if event.down == 1
      shapes << {
        type:  current_shape,
        x:     event.x,
        y:     event.y,
        color: current_color.dup,
      }

      # Limit shapes to prevent memory issues
      if shapes.size > 100
        shapes.shift
      end

      area.queue_redraw_all
    end
  }

  key_event { |area, event|
    if event.up == 0 # Key pressed (not released)
      key_char = event.key.to_s rescue "?"

      # Update last key info
      modifier_text = [] of String
      if event.modifiers.ctrl?
        modifier_text << "Ctrl"
      end
      if event.modifiers.alt?
        modifier_text << "Alt"
      end
      if event.modifiers.shift?
        modifier_text << "Shift"
      end

      modifier_str = modifier_text.empty? ? "" : "#{modifier_text.join("+")}+"
      last_key_info = "Key: #{modifier_str}#{key_char} (code: #{event.key})"

      # Handle specific keys
      case event.key
      when '1'.ord
        current_shape = :rectangle
      when '2'.ord
        current_shape = :circle
      when '3'.ord
        current_shape = :triangle
      when 'r'.ord, 'R'.ord
        current_color = {r: 0.8, g: 0.2, b: 0.2} # Red
      when 'g'.ord, 'G'.ord
        current_color = {r: 0.2, g: 0.8, b: 0.2} # Green
      when 'b'.ord, 'B'.ord
        current_color = {r: 0.2, g: 0.2, b: 0.8} # Blue
      when 'y'.ord, 'Y'.ord
        current_color = {r: 0.8, g: 0.8, b: 0.2} # Yellow
      when 'c'.ord, 'C'.ord
        shapes.clear
      when ' '.ord # Spacebar
        # Add random shape at center
        shapes << {
          type:  current_shape,
          x:     250.0,
          y:     200.0,
          color: current_color.dup,
        }
      end

      area.queue_redraw_all
    end
    true
  }
end

window = UIng::Window.new("Area - Keyboard Input", 500, 400)
window.on_closing do
  UIng.quit
  true
end

# Create info labels
info_label1 = UIng::Label.new("Shapes: 1=Rectangle, 2=Circle, 3=Triangle")
info_label2 = UIng::Label.new("Colors: R=Red, G=Green, B=Blue, Y=Yellow")
info_label3 = UIng::Label.new("Actions: Click to place shape, Space=Center, C=Clear")

area = UIng::Area.new(handler)
box = UIng::Box.new(:vertical, padded: true)
box.append(info_label1, stretchy: false)
box.append(info_label2, stretchy: false)
box.append(info_label3, stretchy: false)
box.append(area, stretchy: true)
window.child = box

window.show

UIng.main
UIng.uninit
