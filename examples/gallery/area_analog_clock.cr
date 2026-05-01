require "../../src/uing"

class ClockDrawer
  getter ctx : UIng::Area::Draw::Context
  getter center_x : Float64
  getter center_y : Float64
  getter radius : Float64

  @black_brush : UIng::Area::Draw::Brush
  @red_brush : UIng::Area::Draw::Brush
  @stroke_thin : UIng::Area::Draw::StrokeParams
  @stroke_mid : UIng::Area::Draw::StrokeParams
  @stroke_thick : UIng::Area::Draw::StrokeParams

  def initialize(@ctx : UIng::Area::Draw::Context, @center_x : Float64, @center_y : Float64, radius : Float64)
    @radius = radius.clamp(10.0, Float64::MAX)
    # brushes
    @black_brush = UIng::Area::Draw::Brush.new(:solid, 0.0, 0.0, 0.0, 1.0)
    @red_brush = UIng::Area::Draw::Brush.new(:solid, 0.8, 0.0, 0.0, 1.0)
    # stroke params (reused)
    @stroke_thin = stroke_params(1.0)
    @stroke_mid = stroke_params(3.0)
    @stroke_thick = stroke_params(6.0)
  end

  # Create common stroke parameters
  private def stroke_params(thickness : Float64)
    UIng::Area::Draw::StrokeParams.new(
      cap: :round, join: :round,
      thickness: thickness, miter_limit: 10.0
    )
  end

  # Convert polar coordinates to cartesian
  private def polar_to_cartesian(radius : Float64, angle : Float64)
    {center_x + radius * Math.cos(angle), center_y + radius * Math.sin(angle)}
  end

  # Draw clock face outline
  def draw_clock_face
    ctx.stroke_path(@black_brush, @stroke_mid) do |path|
      path.new_figure_with_arc(center_x, center_y, radius, 0, Math::PI * 2, false)
    end
  end

  # Draw 12-hour markers
  def draw_hour_markers
    12.times do |i|
      angle = i * Math::PI / 6 - Math::PI / 2
      inner_x, inner_y = polar_to_cartesian(radius - 15.0, angle)
      outer_x, outer_y = polar_to_cartesian(radius - 5.0, angle)
      ctx.stroke_path(@black_brush, @stroke_mid) do |path|
        path.new_figure(inner_x, inner_y)
        path.line_to(outer_x, outer_y)
      end
    end
  end

  # Draw a clock hand
  def draw_hand(angle : Float64, length : Float64, stroke : UIng::Area::Draw::StrokeParams, hand_brush : UIng::Area::Draw::Brush)
    end_x, end_y = polar_to_cartesian(length, angle)
    ctx.stroke_path(hand_brush, stroke) do |path|
      path.new_figure(center_x, center_y)
      path.line_to(end_x, end_y)
    end
  end

  # Draw center dot (fill + tiny outline)
  def draw_center_dot
    ctx.fill_path(@black_brush) do |path|
      path.new_figure_with_arc(center_x, center_y, 4.5, 0, Math::PI * 2, false)
    end
    ctx.stroke_path(@black_brush, @stroke_thin) do |path|
      path.new_figure_with_arc(center_x, center_y, 4.5, 0, Math::PI * 2, false)
    end
  end

  # Draw all hands for a given time
  def draw_hands(now : Time)
    # High-resolution sweep (continuous rotation)
    sec = now.second + now.nanosecond / 1_000_000_000.0
    min = now.minute + sec / 60.0
    hour = (now.hour % 12) + min / 60.0

    # Offset by -π/2 to make 12 o'clock point up
    hour_angle = hour * Math::PI / 6 - Math::PI / 2
    minute_angle = min * Math::PI / 30 - Math::PI / 2
    second_angle = sec * Math::PI / 30 - Math::PI / 2

    draw_hand(hour_angle, radius * 0.52, @stroke_thick, @black_brush)
    draw_hand(minute_angle, radius * 0.76, @stroke_mid, @black_brush)
    draw_hand(second_angle, radius * 0.85, @stroke_thin, @red_brush)
  end

  # Draw complete clock
  def draw_clock(now : Time = Time.local)
    draw_clock_face
    draw_hour_markers
    draw_hands(now)
    draw_center_dot
  end
end

UIng.init

handler = UIng::Area::Handler.new do
  draw { |area, params|
    center_x, center_y = params.area_width / 2.0, params.area_height / 2.0
    # Ensure 20px margin while clamping radius to minimum 10
    radius = Math.min(params.area_width, params.area_height) / 2.0 - 20.0
    radius = radius.clamp(10.0, Float64::MAX)

    clock_drawer = ClockDrawer.new(params.context, center_x, center_y, radius)
    clock_drawer.draw_clock(Time.local)
  }
end

window = UIng::Window.new("Simple Analog Clock", 300, 300)
window.on_closing { UIng.quit; true }

area = UIng::Area.new(handler)
window.child = UIng::Box.new(:vertical, padded: true).tap(&.append(area, stretchy: true))

window.show

# Higher FPS for smooth sweep second hand (reduce to 33ms if CPU load is a concern)
UIng.timer(16) { area.queue_redraw_all; 1 }

UIng.main
UIng.uninit
