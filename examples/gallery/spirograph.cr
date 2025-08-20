require "../../src/uing"

# Spirograph parameters and logic
module Spirograph
  # Spirograph parameters (textbook notation)
  @@R : Float64 = 120.0       # Radius of fixed circle
  @@r : Float64 = 60.0        # Radius of rolling circle
  @@a : Float64 = 80.0        # Offset from center of rolling circle
  @@num_points : Int32 = 2000 # Number of points

  # Center of drawing area
  @@center_x : Float64 = 300.0
  @@center_y : Float64 = 250.0

  # Color phase for animation
  @@hue : Float64 = 0.0

  def self.radius_fixed
    @@R
  end

  def self.radius_rolling
    @@r
  end

  def self.offset
    @@a
  end

  def self.num_points
    @@num_points
  end

  def self.center_x
    @@center_x
  end

  def self.center_y
    @@center_y
  end

  def self.hue
    @@hue
  end

  def self.set_radius_fixed(v : Float64)
    @@R = v.clamp(30.0, 200.0)
  end

  def self.set_radius_rolling(v : Float64)
    @@r = v.clamp(10.0, 100.0)
  end

  def self.set_offset(v : Float64)
    @@a = v.clamp(5.0, 150.0)
  end

  def self.set_hue(v : Float64)
    @@hue = v
  end

  # Greatest common divisor (Euclidean algorithm)
  def self.gcd(u : Float64, v : Float64) : Float64
    u, v = u.abs, v.abs
    while v > 1e-6
      u, v = v, u % v
    end
    u
  end

  # Least common multiple
  def self.lcm(u : Float64, v : Float64) : Float64
    (u * v).abs / gcd(u, v)
  end

  # Total angle to complete the spirograph
  def self.total_angle : Float64
    lcm(@@R, @@r) * 2 * Math::PI / @@r
  end

  # Parametric equations for spirograph (textbook style)
  def self.spiro_x(t : Float64)
    (radius_fixed - radius_rolling) * Math.cos(t) + offset * Math.cos((radius_fixed - radius_rolling) / radius_rolling * t) + center_x
  end

  def self.spiro_y(t : Float64)
    (radius_fixed - radius_rolling) * Math.sin(t) - offset * Math.sin((radius_fixed - radius_rolling) / radius_rolling * t) + center_y
  end

  # HSV to RGB conversion
  def self.hsv_to_rgb(h : Float64, s : Float64, v : Float64)
    h = h % 1.0
    i = (h * 6).floor
    f = h * 6 - i
    p = v * (1 - s)
    q = v * (1 - f * s)
    t = v * (1 - (1 - f) * s)
    case i % 6
    when 0; {r: v, g: t, b: p}
    when 1; {r: q, g: v, b: p}
    when 2; {r: p, g: v, b: t}
    when 3; {r: p, g: q, b: v}
    when 4; {r: t, g: p, b: v}
    else    {r: v, g: p, b: q}
    end
  end
end

# Main application class for GC protection and UI management
class SpirographApp
  # Handler, area, and window are kept as instance variables for GC protection
  @handler : UIng::Area::Handler
  @area : UIng::Area
  @main_window : UIng::Window
  @info_label : UIng::Label

  def initialize
    # Randomize initial parameters
    Spirograph.set_radius_fixed(50.0 + rand * 150.0)
    Spirograph.set_radius_rolling(10.0 + rand * 90.0)
    Spirograph.set_offset(10.0 + rand * 120.0)
    Spirograph.set_hue(rand)

    # Create handler and area
    @handler = UIng::Area::Handler.new
    @area = UIng::Area.new(@handler)
    @main_window = UIng::Window.new("Spirograph Example", 600, 500)
    @info_label = UIng::Label.new("Click: Randomize | Q/A: R | W/S: r | E/D: a")

    setup_handlers
    setup_ui
  end

  # Set up all event handlers (draw, mouse, key)
  private def setup_handlers
    @handler.draw do |area, params|
      ctx = params.context

      # Draw background
      bg_brush = UIng::Area::Draw::Brush.new(:solid, 0.1, 0.1, 0.15, 1.0)
      ctx.fill_path(bg_brush) do |path|
        path.add_rectangle(0, 0, 600, 500)
      end

      # Draw spirograph curve
      total_theta = Spirograph.total_angle
      n_points = Spirograph.num_points
      hue = Spirograph.hue

      # Color changes slightly on each redraw using hue
      rgb = Spirograph.hsv_to_rgb(hue, 0.7, 0.95)
      r = rgb["r"]? || rgb[:r]
      g = rgb["g"]? || rgb[:g]
      b = rgb["b"]? || rgb[:b]

      ctx.stroke_path(
        UIng::Area::Draw::Brush.new(:solid, r, g, b, 1.0),
        cap: :round,
        join: :round,
        thickness: 1.0
      ) do |path|
        t0 = 0.0
        x0 = Spirograph.spiro_x(t0)
        y0 = Spirograph.spiro_y(t0)
        path.new_figure(x0, y0)
        (1..n_points).each do |i|
          t = total_theta * i / n_points
          x = Spirograph.spiro_x(t)
          y = Spirograph.spiro_y(t)
          path.line_to(x, y)
        end
      end
    end

    # Mouse event: randomize parameters and redraw
    @handler.mouse_event do |area, event|
      Spirograph.set_radius_fixed(50.0 + rand * 150.0)
      Spirograph.set_radius_rolling(10.0 + rand * 90.0)
      Spirograph.set_offset(10.0 + rand * 120.0)
      # Advance hue slightly on each redraw
      Spirograph.set_hue((Spirograph.hue + 0.02) % 1.0)
      area.queue_redraw_all
      update_info_label
    end

    # Key event: adjust parameters
    @handler.key_event do |area, event|
      if event.up == 0 # Key down
        case event.key
        when 'Q'.ord, 'q'.ord
          Spirograph.set_radius_fixed(Spirograph.radius_fixed + 5)
        when 'A'.ord, 'a'.ord
          Spirograph.set_radius_fixed(Spirograph.radius_fixed - 5)
        when 'W'.ord, 'w'.ord
          Spirograph.set_radius_rolling(Spirograph.radius_rolling + 2)
        when 'S'.ord, 's'.ord
          Spirograph.set_radius_rolling(Spirograph.radius_rolling - 2)
        when 'E'.ord, 'e'.ord
          Spirograph.set_offset(Spirograph.offset + 5)
        when 'D'.ord, 'd'.ord
          Spirograph.set_offset(Spirograph.offset - 5)
        end
        area.queue_redraw_all
        update_info_label
      end
      true
    end
  end

  # Set up the UI layout
  private def setup_ui
    box = UIng::Box.new(:vertical)
    box.padded = true
    box.append(@info_label, false)
    box.append(@area, true)

    @main_window.child = box
    @main_window.margined = true

    @main_window.on_closing do
      UIng.quit
      true
    end
  end

  # Update the info label to show current parameters
  private def update_info_label
    @info_label.text = "Q/A: R=#{Spirograph.radius_fixed.to_i} | W/S: r=#{Spirograph.radius_rolling.to_i} | E/D: a=#{Spirograph.offset.to_i}"
  end

  # Run the application
  def run
    @main_window.show
    UIng.main
    UIng.uninit
  end
end

# Entry point
UIng.init
SpirographApp.new.run
