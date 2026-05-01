require "../../src/uing"

UIng.init

# Colors and brushes example
# Demonstrates: Different brush types, gradients, transparency, color mixing

# Helper function to create muted colors (reduce saturation)
def mute(r : Float64, g : Float64, b : Float64, factor : Float64 = 0.5) : NamedTuple(r: Float64, g: Float64, b: Float64)
  # Mix with gray to reduce saturation
  gray = 0.5
  muted_r = r * (1.0 - factor) + gray * factor
  muted_g = g * (1.0 - factor) + gray * factor
  muted_b = b * (1.0 - factor) + gray * factor
  {r: muted_r, g: muted_g, b: muted_b}
end

handler = UIng::Area::Handler.new do
  draw { |area, params|
    ctx = params.context

    # Fill background with white for better color visibility
    # type, r, g, b, a
    white_brush = UIng::Area::Draw::Brush.new(:solid, 1.0, 1.0, 1.0, 1.0)
    ctx.fill_path(white_brush) do |path|
      # x, y, width, height (fill entire area)
      path.add_rectangle(0, 0, 450, 320)
    end

    # Primary color overlapping demonstration (RGB additive color mixing)
    # Semi-transparent red (shifted position for clear overlap visibility)
    # type, r, g, b, a
    red_brush = UIng::Area::Draw::Brush.new(:solid, 1.0, 0.0, 0.0, 0.5)
    ctx.fill_path(red_brush) do |path|
      # x, y, width, height
      path.add_rectangle(40, 40, 70, 70)
    end

    # Semi-transparent green (overlapping with red)
    # type, r, g, b, a
    green_brush = UIng::Area::Draw::Brush.new(:solid, 0.0, 1.0, 0.0, 0.5)
    ctx.fill_path(green_brush) do |path|
      # x, y, width, height
      path.add_rectangle(70, 55, 70, 70)
    end

    # Semi-transparent blue (overlapping with both red and green)
    # type, r, g, b, a
    blue_brush = UIng::Area::Draw::Brush.new(:solid, 0.0, 0.0, 1.0, 0.5)
    ctx.fill_path(blue_brush) do |path|
      # x, y, width, height
      path.add_rectangle(55, 70, 70, 70)
    end

    # Horizontal linear gradient brush
    horizontal_gradient_stops = [
      # pos, r, g, b, a
      UIng::Area::Draw::Brush::GradientStop.new(0.0, 1.0, 1.0, 0.0, 1.0), # Yellow
      UIng::Area::Draw::Brush::GradientStop.new(0.5, 1.0, 0.5, 0.0, 1.0), # Orange
      UIng::Area::Draw::Brush::GradientStop.new(1.0, 1.0, 0.0, 0.0, 1.0), # Red
    ]

    horizontal_gradient = UIng::Area::Draw::Brush.new(
      :linear_gradient,
      x0: 50, y0: 160,
      x1: 170, y1: 160,
      stops: horizontal_gradient_stops
    )
    ctx.fill_path(horizontal_gradient) do |path|
      # x, y, width, height
      path.add_rectangle(30, 150, 150, 30)
    end

    # Vertical linear gradient brush
    vertical_gradient_stops = [
      # pos, r, g, b, a
      UIng::Area::Draw::Brush::GradientStop.new(0.0, 0.0, 0.5, 1.0, 1.0), # Blue
      UIng::Area::Draw::Brush::GradientStop.new(0.5, 0.5, 0.0, 1.0, 1.0), # Purple
      UIng::Area::Draw::Brush::GradientStop.new(1.0, 1.0, 0.0, 0.5, 1.0), # Pink
    ]

    vertical_gradient = UIng::Area::Draw::Brush.new(
      :linear_gradient,
      x0: 100, y0: 200,
      x1: 120, y1: 280,
      stops: vertical_gradient_stops
    )
    ctx.fill_path(vertical_gradient) do |path|
      # x, y, width, height
      path.add_rectangle(60, 200, 100, 80)
    end

    # Simple radial gradient brush
    radial_stops = [
      # pos, r, g, b, a
      UIng::Area::Draw::Brush::GradientStop.new(0.0, 1.0, 0.0, 1.0, 1.0), # Magenta
      UIng::Area::Draw::Brush::GradientStop.new(0.5, 0.0, 1.0, 1.0, 1.0), # Cyan
      UIng::Area::Draw::Brush::GradientStop.new(1.0, 0.0, 1.0, 0.0, 1.0), # Lime
    ]

    radial_gradient = UIng::Area::Draw::Brush.new(
      :radial_gradient,
      x0: 260, y0: 30,
      outer_radius: 360,
      stops: radial_stops
    )
    ctx.fill_path(radial_gradient) do |path|
      # x_center, y_center, radius, start_angle, sweep, negative
      path.new_figure_with_arc(260, 30, 90, 0, Math::PI, false)
    end

    # Color spectrum with varying saturation using mute function
    # Base colors (high saturation)
    base_colors = [
      {r: 1.0, g: 0.0, b: 0.0}, # Red
      {r: 1.0, g: 0.5, b: 0.0}, # Orange
      {r: 1.0, g: 1.0, b: 0.0}, # Yellow
      {r: 0.0, g: 1.0, b: 0.0}, # Green
      {r: 0.0, g: 0.0, b: 1.0}, # Blue
      {r: 0.5, g: 0.0, b: 1.0}, # Purple
      {r: 1.0, g: 1.0, b: 1.0}, # White
      {r: 0.0, g: 0.0, b: 0.0}, # Black
    ]

    # Draw color rows with different saturation levels using loop
    saturation_levels = [
      {mute_factor: 0.0}, # High saturation (no muting)
      {mute_factor: 0.2}, # Medium saturation
      {mute_factor: 0.4}, # Low saturation
      {mute_factor: 0.6}, # Very low saturation
      {mute_factor: 0.8}, # Almost gray
      {mute_factor: 1.0}, # Gray (fully muted)
    ]

    row_height = (280 - 150) // saturation_levels.size # Auto-calculate height based on available space

    saturation_levels.each_with_index do |level, row_index|
      y_position = 150 + row_index * row_height
      base_colors.each_with_index do |color, i|
        final_color = mute(color[:r], color[:g], color[:b], level[:mute_factor])
        # type, r, g, b, a
        brush = UIng::Area::Draw::Brush.new(:solid, final_color[:r], final_color[:g], final_color[:b], 1.0)
        ctx.fill_path(brush) do |path|
          # x, y, width, height (height auto-calculated)
          path.add_rectangle(210 + i * 18, y_position, 16, row_height - 2)
        end
      end
    end
  }
end

window = UIng::Window.new("Area - Colors and Brushes", 400, 300)
window.on_closing do
  UIng.quit
  true
end

area = UIng::Area.new(handler)
box = UIng::Box.new(:vertical, padded: false)
box.append(area, stretchy: true)
window.child = box

window.show

UIng.main
UIng.uninit
