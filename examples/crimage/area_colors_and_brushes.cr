require "../../src/uing/crimage"

UIng.init

# Solid color, opacity, linear and radial gradients, and color mixing.
module BrushGallery
  alias Draw = UIng::Area::Draw
  alias Color = CrImage::Color

  WIDTH  = 404.0
  HEIGHT = 220.0

  RED     = Color.parse("#FF1A2E")
  YELLOW  = Color.parse("#FFDB14")
  GREEN   = Color.parse("#1FF057")
  CYAN    = Color.parse("#05D6FF")
  BLUE    = Color.parse("#294DFF")
  MAGENTA = Color.parse("#FF1AA6")

  FONT = UIng::FontDescriptor.new(size: 8, weight: UIng::TextWeight::SemiBold)

  def self.solid(color : Color::Color, alpha : Float64 = 1.0) : Draw::Brush
    Draw::Brush.solid(color).tap(&.a=(alpha))
  end

  # A slight shadow keeps the small white labels readable on bright colors.
  def self.text(ctx : Draw::Context, label : String, x : Number, y : Number, width : Number,
                align : Draw::TextAlign = Draw::TextAlign::Left) : Nil
    2.times do |pass|
      color = pass.zero? ? Color::NRGBA.new(0, 0, 0, 115) : Color::WHITE
      offset = pass.zero? ? 0.7 : 0.0
      UIng::Area::AttributedString.open(label) do |string|
        string.set_attribute(UIng::Area::Attribute.new_color(color), 0, string.len)
        Draw::TextLayout.open(string: string, default_font: FONT, width: width, align: align) do |layout|
          ctx.draw_text_layout(layout, x + offset, y + offset)
        end
      end
    end
  end

  def self.rect(ctx : Draw::Context, brush : Draw::Brush,
                x : Number, y : Number, width : Number, height : Number) : Nil
    ctx.fill_path(brush) { |path| path.add_rectangle(x, y, width, height) }
  end

  def self.circle(ctx : Draw::Context, brush : Draw::Brush, x : Number, y : Number, radius : Number) : Nil
    ctx.fill_path(brush) do |path|
      path.new_figure_with_arc(x, y, radius, 0, Math::PI * 2, false)
    end
  end

  def self.draw_solid(ctx : Draw::Context) : Nil
    # Cyan, warm yellow, and magenta share the same opacity. The circle
    # centers form an equilateral triangle, keeping each color easy to see.
    circle(ctx, solid(CYAN, 0.7), 51.5, 40, 32)
    circle(ctx, solid(YELLOW, 0.7), 76.5, 40 + 25 * Math.sqrt(3), 32)
    circle(ctx, solid(MAGENTA, 0.7), 101.5, 40, 32)
    text(ctx, "alpha 0.7", 43, 91, 67, :center)
  end

  def self.draw_linear(ctx : Draw::Context) : Nil
    horizontal_stops = [
      Draw::Brush::GradientStop.new(0.0, MAGENTA),
      Draw::Brush::GradientStop.new(0.5, RED),
      Draw::Brush::GradientStop.new(1.0, YELLOW),
    ]
    horizontal = Draw::Brush.new(:linear_gradient,
      x0: 158, y0: 24, x1: 396, y1: 24, stops: horizontal_stops)
    rect(ctx, horizontal, 158, 8, 238, 32)
    text(ctx, "linear / 3 stops", 164, 16, 226)

    vertical_stops = [
      Draw::Brush::GradientStop.new(0.0, BLUE),
      Draw::Brush::GradientStop.new(0.5, CYAN),
      Draw::Brush::GradientStop.new(1.0, GREEN),
    ]
    vertical = Draw::Brush.new(:linear_gradient,
      x0: 193, y0: 46, x1: 193, y1: 116, stops: vertical_stops)
    rect(ctx, vertical, 158, 46, 70, 70)
    text(ctx, "vertical", 164, 51, 58)

    # Alpha stops fade the cyan brush into the checkerboard underneath it.
    rect(ctx, solid(Color.gray(20)), 236, 46, 160, 70)
    ctx.fill_path(solid(Color.gray(36))) do |path|
      5.times do |row|
        10.times do |column|
          next if (row + column).even?
          path.add_rectangle(236 + column * 16, 46 + row * 14, 16, 14)
        end
      end
    end
    fade_out = Draw::Brush::GradientStop.new(1.0, CYAN)
    fade_out.a = 0.0
    alpha_stops = [Draw::Brush::GradientStop.new(0.0, CYAN), fade_out]
    alpha_gradient = Draw::Brush.new(:linear_gradient,
      x0: 236, y0: 81, x1: 396, y1: 81, stops: alpha_stops)
    rect(ctx, alpha_gradient, 236, 46, 160, 70)
    text(ctx, "alpha stops", 242, 51, 148)
  end

  def self.draw_radial(ctx : Draw::Context) : Nil
    warm_edge = MAGENTA.darken(0.45)
    centered_stops = [
      Draw::Brush::GradientStop.new(0.0, Color::WHITE),
      Draw::Brush::GradientStop.new(0.18, YELLOW),
      Draw::Brush::GradientStop.new(0.5, RED),
      Draw::Brush::GradientStop.new(1.0, warm_edge),
    ]
    centered = Draw::Brush.new(:radial_gradient,
      x0: 51, y0: 169, x1: 51, y1: 169, outer_radius: 43, stops: centered_stops)
    circle(ctx, centered, 51, 169, 43)
    text(ctx, "radial\ncentered", 16, 176, 70, :center)

    cool_edge = BLUE.darken(0.45)
    offset_stops = [
      Draw::Brush::GradientStop.new(0.0, Color::WHITE),
      Draw::Brush::GradientStop.new(0.18, GREEN),
      Draw::Brush::GradientStop.new(0.5, CYAN),
      Draw::Brush::GradientStop.new(1.0, cool_edge),
    ]
    offset = Draw::Brush.new(:radial_gradient,
      x0: 125, y0: 151, x1: 145, y1: 169, outer_radius: 43, stops: offset_stops)
    circle(ctx, offset, 145, 169, 43)
    text(ctx, "radial\noffset", 110, 176, 70, :center)
  end

  def self.draw_color_mixing(ctx : Draw::Context) : Nil
    colors = [RED, YELLOW, GREEN, CYAN, BLUE, MAGENTA]
    amounts = [0.0, 0.33, 0.67, 1.0]
    amounts.each_with_index do |amount, row|
      colors.each_with_index do |color, column|
        mixed = color.blend(Color::GRAY, amount)
        rect(ctx, solid(mixed), 200 + column * 33, 126 + row * 22, 32, 18)
      end
      text(ctx, "#{(amount * 100).round.to_i}%", 200, 128 + row * 22, 32, :center)
    end
    text(ctx, "gray mix", 239, 194, 150)
  end

  def self.draw(params : Draw::Params) : Nil
    return if params.area_width <= 0 || params.area_height <= 0
    ctx = params.context
    rect(ctx, solid(Color::BLACK), 0, 0, params.area_width, params.area_height)

    scale = Math.min(params.area_width / WIDTH, params.area_height / HEIGHT)
    matrix = Draw::Matrix.new.set_identity
    matrix.translate((params.area_width - WIDTH * scale) / 2, (params.area_height - HEIGHT * scale) / 2)
    matrix.scale(0, 0, scale, scale)
    ctx.save
    begin
      ctx.transform(matrix)
      draw_solid(ctx)
      draw_linear(ctx)
      draw_radial(ctx)
      draw_color_mixing(ctx)
    ensure
      ctx.restore
    end
  end
end

handler = UIng::Area::Handler.new do
  draw do |_area, params|
    BrushGallery.draw(params)
  end
end

window = UIng::Window.new("Area - Colors and Brushes", 404, 220)
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
