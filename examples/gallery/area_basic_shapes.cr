require "../../src/uing"

UIng.init

# Basic shapes drawing example
# Demonstrates: Area setup, basic drawing operations, solid brushes, simple paths

handler = UIng::Area::Handler.new do
  draw { |area, params|
    ctx = params.context

    # Draw a blue rectangle
    blue_brush = UIng::Area::Draw::Brush.new(:solid, 0.2, 0.4, 0.8, 1.0)
    ctx.fill_path(blue_brush) do |path|
      # x, y, width, height
      path.add_rectangle(30, 30, 70, 45)
    end

    # Draw a red circle (using arc)
    red_brush = UIng::Area::Draw::Brush.new(:solid, 0.8, 0.2, 0.2, 1.0)
    ctx.fill_path(red_brush) do |path|
      # x_center, y_center, radius, start_angle, sweep, negative
      path.new_figure_with_arc(200, 50, 30, 0, Math::PI * 2, false)
    end

    # Draw a green triangle (using lines)
    green_brush = UIng::Area::Draw::Brush.new(:solid, 0.2, 0.8, 0.2, 1.0)
    ctx.fill_path(green_brush) do |path|
      # x, y (starting point)
      path.new_figure(75, 110)
      # x, y (line to point)
      path.line_to(110, 160)
      # x, y (line to point)
      path.line_to(40, 160)
      path.close_figure
    end

    # Draw a purple outlined rectangle (stroke only)
    purple_brush = UIng::Area::Draw::Brush.new(:solid, 0.6, 0.2, 0.8, 1.0)
    stroke_params = UIng::Area::Draw::StrokeParams.new(
      cap: :flat,
      join: :miter,
      thickness: 2.5,
      miter_limit: 10.0
    )
    ctx.stroke_path(purple_brush, stroke_params) do |path|
      # x, y, width, height
      path.add_rectangle(190, 110, 60, 50)
    end
  }
end

window = UIng::Window.new("Area - Basic Shapes", 300, 200)
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
