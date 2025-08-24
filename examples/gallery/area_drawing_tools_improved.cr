require "../../src/uing"

UIng.init

# Improved drawing tools example
# Demonstrates: Mouse dragging, line drawing with individual color/thickness, undo functionality

# Class to store each drawn path with its properties
class DrawnPath
  property points : Array({x: Float64, y: Float64})
  property color : {r: Float64, g: Float64, b: Float64}
  property brush_size : Float64

  def initialize(@points : Array({x: Float64, y: Float64}), @color : {r: Float64, g: Float64, b: Float64}, @brush_size : Float64)
  end
end

# Drawing state
drawing = false
current_path = [] of {x: Float64, y: Float64}
completed_paths = [] of DrawnPath
undo_stack = [] of DrawnPath # For redo functionality
current_brush_size = 3.0
current_color = {r: 0.2, g: 0.2, b: 0.8}

# Memory management constants
MAX_PATHS           = 100
MAX_UNDO_STACK      =  50
MAX_POINTS_PER_PATH = 500

handler = UIng::Area::Handler.new do
  draw { |area, params|
    ctx = params.context

    # Draw white background
    bg_brush = UIng::Area::Draw::Brush.new(:solid, 1.0, 1.0, 1.0, 1.0)
    ctx.fill_path(bg_brush) do |path|
      path.add_rectangle(0, 0, 700, 500)
    end

    # Draw toolbar background
    toolbar_brush = UIng::Area::Draw::Brush.new(:solid, 0.9, 0.9, 0.9, 1.0)
    ctx.fill_path(toolbar_brush) do |path|
      path.add_rectangle(0, 0, 700, 60)
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
      path.add_rectangle(0, 60, 700, 1)
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
      {r: 0.5, g: 0.3, b: 0.1}, # Brown
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
    [1.0, 3.0, 6.0, 10.0, 15.0].each_with_index do |size, i|
      indicator_brush = UIng::Area::Draw::Brush.new(:solid, 0.3, 0.3, 0.3, 1.0)
      ctx.fill_path(indicator_brush) do |path|
        path.new_figure_with_arc(250 + i * 35, 30, size / 2, 0, Math::PI * 2, false)
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
          path.new_figure_with_arc(250 + i * 35, 30, size / 2 + 3, 0, Math::PI * 2, false)
        end
      end
    end

    # Draw Undo button
    undo_bg_brush = if completed_paths.empty?
                      UIng::Area::Draw::Brush.new(:solid, 0.8, 0.8, 0.8, 1.0) # Disabled
                    else
                      UIng::Area::Draw::Brush.new(:solid, 0.9, 0.9, 1.0, 1.0) # Enabled
                    end
    ctx.fill_path(undo_bg_brush) do |path|
      path.add_rectangle(450, 10, 60, 40)
    end

    undo_border_brush = UIng::Area::Draw::Brush.new(:solid, 0.5, 0.5, 0.5, 1.0)
    ctx.stroke_path(undo_border_brush, stroke_params) do |path|
      path.add_rectangle(450, 10, 60, 40)
    end

    # Draw Redo button
    redo_bg_brush = if undo_stack.empty?
                      UIng::Area::Draw::Brush.new(:solid, 0.8, 0.8, 0.8, 1.0) # Disabled
                    else
                      UIng::Area::Draw::Brush.new(:solid, 0.9, 1.0, 0.9, 1.0) # Enabled
                    end
    ctx.fill_path(redo_bg_brush) do |path|
      path.add_rectangle(520, 10, 60, 40)
    end

    ctx.stroke_path(undo_border_brush, stroke_params) do |path|
      path.add_rectangle(520, 10, 60, 40)
    end

    # Draw Clear button
    clear_bg_brush = UIng::Area::Draw::Brush.new(:solid, 1.0, 0.9, 0.9, 1.0)
    ctx.fill_path(clear_bg_brush) do |path|
      path.add_rectangle(590, 10, 60, 40)
    end

    ctx.stroke_path(undo_border_brush, stroke_params) do |path|
      path.add_rectangle(590, 10, 60, 40)
    end

    # Draw button labels
    button_font = UIng::FontDescriptor.new(
      family: "Arial",
      size: 10,
      weight: :normal,
      italic: :normal,
      stretch: :normal
    )

    # Undo label
    undo_text = UIng::Area::AttributedString.new("Undo")
    UIng::Area::Draw::TextLayout.open(
      string: undo_text,
      default_font: button_font,
      width: 60,
      align: UIng::Area::Draw::TextAlign::Center
    ) do |text_layout|
      ctx.draw_text_layout(text_layout, 450, 25)
    end
    undo_text.free

    # Redo label
    redo_text = UIng::Area::AttributedString.new("Redo")
    UIng::Area::Draw::TextLayout.open(
      string: redo_text,
      default_font: button_font,
      width: 60,
      align: UIng::Area::Draw::TextAlign::Center
    ) do |text_layout|
      ctx.draw_text_layout(text_layout, 520, 25)
    end
    redo_text.free

    # Clear label
    clear_text = UIng::Area::AttributedString.new("Clear")
    UIng::Area::Draw::TextLayout.open(
      string: clear_text,
      default_font: button_font,
      width: 60,
      align: UIng::Area::Draw::TextAlign::Center
    ) do |text_layout|
      ctx.draw_text_layout(text_layout, 590, 25)
    end
    clear_text.free

    # Draw all completed paths with their individual colors and brush sizes
    completed_paths.each do |drawn_path|
      next if drawn_path.points.size < 2

      path_brush = UIng::Area::Draw::Brush.new(:solid,
        drawn_path.color[:r], drawn_path.color[:g], drawn_path.color[:b], 1.0)
      path_stroke = UIng::Area::Draw::StrokeParams.new(
        cap: :round,
        join: :round,
        thickness: drawn_path.brush_size,
        miter_limit: 10.0
      )

      ctx.stroke_path(path_brush, path_stroke) do |path|
        first_point = drawn_path.points.first
        path.new_figure(first_point[:x], first_point[:y])

        drawn_path.points[1..].each do |point|
          path.line_to(point[:x], point[:y])
        end
      end
    end

    # Draw current path being drawn (with current color and brush size)
    if current_path.size >= 2
      current_brush = UIng::Area::Draw::Brush.new(:solid, current_color[:r], current_color[:g], current_color[:b], 1.0)
      current_stroke = UIng::Area::Draw::StrokeParams.new(
        cap: :round,
        join: :round,
        thickness: current_brush_size,
        miter_limit: 10.0
      )

      ctx.stroke_path(current_brush, current_stroke) do |path|
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
    if event.y <= 60
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
            {r: 0.5, g: 0.3, b: 0.1}, # Brown
          ]
          if color_index >= 0 && color_index < colors.size
            current_color = colors[color_index]
          end
        end

        # Brush size clicks
        if event.x >= 250 && event.x <= 425
          size_index = ((event.x - 250) / 35).to_i
          sizes = [1.0, 3.0, 6.0, 10.0, 15.0]
          if size_index >= 0 && size_index < sizes.size
            current_brush_size = sizes[size_index]
          end
        end

        # Undo button
        if event.x >= 450 && event.x <= 510 && !completed_paths.empty?
          undo_stack << completed_paths.pop
          # Limit undo stack size
          if undo_stack.size > MAX_UNDO_STACK
            undo_stack.shift
          end
        end

        # Redo button
        if event.x >= 520 && event.x <= 580 && !undo_stack.empty?
          completed_paths << undo_stack.pop
        end

        # Clear button
        if event.x >= 590 && event.x <= 650
          completed_paths.clear
          undo_stack.clear
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
      # Clear redo stack when starting new drawing
      undo_stack.clear
    elsif event.up == 1 # Left mouse button released
      if drawing && current_path.size > 0
        # Limit points per path for memory safety
        limited_path = if current_path.size > MAX_POINTS_PER_PATH
                         current_path.last(MAX_POINTS_PER_PATH)
                       else
                         current_path.dup
                       end

        # Save the path with current color and brush size
        drawn_path = DrawnPath.new(limited_path, current_color.dup, current_brush_size)
        completed_paths << drawn_path

        # Limit total number of paths
        if completed_paths.size > MAX_PATHS
          completed_paths.shift
        end

        current_path.clear
        drawing = false
      end
    elsif drawing && event.held1_to64 == 1 # Dragging with left button
      current_path << {x: event.x, y: event.y}

      # Limit current path length to prevent memory issues
      if current_path.size > MAX_POINTS_PER_PATH
        current_path.shift
      end
    end

    area.queue_redraw_all
  }

  key_event { |area, event|
    if event.up == 0 # Key pressed
      case event.key
      when 'z'.ord, 'Z'.ord
        # Undo with Ctrl+Z
        if event.modifiers.ctrl? && !completed_paths.empty?
          undo_stack << completed_paths.pop
          area.queue_redraw_all
        end
      when 'y'.ord, 'Y'.ord
        # Redo with Ctrl+Y
        if event.modifiers.ctrl? && !undo_stack.empty?
          completed_paths << undo_stack.pop
          area.queue_redraw_all
        end
      when 'c'.ord, 'C'.ord
        # Clear all with Ctrl+C
        if event.modifiers.ctrl?
          completed_paths.clear
          undo_stack.clear
          current_path.clear
          area.queue_redraw_all
        end
      end
    end
    true
  }
end

window = UIng::Window.new("Improved Drawing Tools", 700, 500)
window.on_closing do
  UIng.quit
  true
end

# Create info label
info_label = UIng::Label.new("🎨 Click colors and brush sizes. Draw with mouse. Undo/Redo buttons or Ctrl+Z/Ctrl+Y. Ctrl+C = Clear all")

area = UIng::Area.new(handler)
box = UIng::Box.new(:vertical, padded: true)
box.append(info_label, stretchy: false)
box.append(area, stretchy: true)
window.child = box

window.show

UIng.main
UIng.uninit
