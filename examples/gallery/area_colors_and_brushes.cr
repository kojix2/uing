require "../../src/uing"

UIng.init

# Colors and brushes example
# Demonstrates: Different brush types, gradients, transparency, color mixing

handler = UIng::Area::Handler.new do
  draw { |area, params|
    ctx = params.context

    # Solid color rectangles with different opacities
    # Semi-transparent red
    red_brush = UIng::Area::Draw::Brush.new(:solid, 1.0, 0.0, 0.0, 0.7)
    ctx.fill_path(red_brush) do |path|
      path.add_rectangle(50, 50, 80, 80)
    end

    # Semi-transparent blue (overlapping with red)
    blue_brush = UIng::Area::Draw::Brush.new(:solid, 0.0, 0.0, 1.0, 0.7)
    ctx.fill_path(blue_brush) do |path|
      path.add_rectangle(100, 50, 80, 80)
    end

    # Linear gradient brush
    gradient_stops = [
      UIng::Area::Draw::Brush::GradientStop.new(0.0, 1.0, 1.0, 0.0, 1.0), # Yellow
      UIng::Area::Draw::Brush::GradientStop.new(0.5, 1.0, 0.5, 0.0, 1.0), # Orange
      UIng::Area::Draw::Brush::GradientStop.new(1.0, 1.0, 0.0, 0.0, 1.0), # Red
    ]

    linear_gradient = UIng::Area::Draw::Brush.new(
      :linear_gradient,
      x0: 50, y0: 180,
      x1: 200, y1: 180,
      stops: gradient_stops
    )
    ctx.fill_path(linear_gradient) do |path|
      path.add_rectangle(50, 180, 150, 60)
    end

    # Radial gradient brush
    radial_stops = [
      UIng::Area::Draw::Brush::GradientStop.new(0.0, 1.0, 1.0, 1.0, 1.0), # White center
      UIng::Area::Draw::Brush::GradientStop.new(0.7, 0.0, 0.8, 1.0, 1.0), # Cyan
      UIng::Area::Draw::Brush::GradientStop.new(1.0, 0.0, 0.0, 0.5, 1.0), # Dark blue edge
    ]

    radial_gradient = UIng::Area::Draw::Brush.new(
      :radial_gradient,
      x0: 300, y0: 120,
      outer_radius: 50,
      stops: radial_stops
    )
    ctx.fill_path(radial_gradient) do |path|
      path.new_figure_with_arc(300, 120, 50, 0, Math::PI * 2, false)
    end

    # Color spectrum using multiple solid brushes
    colors = [
      {r: 1.0, g: 0.0, b: 0.0}, # Red
      {r: 1.0, g: 0.5, b: 0.0}, # Orange
      {r: 1.0, g: 1.0, b: 0.0}, # Yellow
      {r: 0.0, g: 1.0, b: 0.0}, # Green
      {r: 0.0, g: 0.0, b: 1.0}, # Blue
      {r: 0.5, g: 0.0, b: 1.0}, # Purple
    ]

    colors.each_with_index do |color, i|
      brush = UIng::Area::Draw::Brush.new(:solid, color[:r], color[:g], color[:b], 0.8)
      ctx.fill_path(brush) do |path|
        path.add_rectangle(250 + i * 15, 200, 12, 80)
      end
    end
  }
end

window = UIng::Window.new("Area - Colors and Brushes", 450, 320)
window.on_closing do
  UIng.quit
  true
end

area = UIng::Area.new(handler)
box = UIng::Box.new(:vertical, padded: true)
box.append(area, stretchy: true)
window.child = box

window.show

UIng.main
UIng.uninit
