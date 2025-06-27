require "../src/uing"

UIng.init

# Application state management with GC protection
module App
  # Keep references to prevent GC
  @@handler : UIng::Area::Handler? = nil
  @@area : UIng::Area? = nil
  @@main_window : UIng::Window? = nil

  def self.handler
    @@handler.not_nil!
  end

  def self.area
    @@area.not_nil!
  end

  def self.main_window
    @@main_window.not_nil!
  end

  def self.set_handler(handler : UIng::Area::Handler)
    @@handler = handler
  end

  def self.set_area(area : UIng::Area)
    @@area = area
  end

  def self.set_main_window(window : UIng::Window)
    @@main_window = window
  end
end

# Random Lines Animation
module RandomLines
  # Line structure
  struct Line
    property x1 : Float64
    property y1 : Float64
    property x2 : Float64
    property y2 : Float64
    property color : NamedTuple(r: Float64, g: Float64, b: Float64)
    property thickness : Float64
    property life : Float64
    property max_life : Float64

    def initialize(@x1 : Float64, @y1 : Float64, @x2 : Float64, @y2 : Float64, @color : NamedTuple(r: Float64, g: Float64, b: Float64), @thickness : Float64, @max_life : Float64)
      @life = @max_life
    end

    def update
      @life -= 0.008
    end

    def alive?
      @life > 0
    end

    def alpha
      (@life / @max_life).clamp(0.0, 1.0)
    end
  end

  CANVAS_WIDTH  = 600.0
  CANVAS_HEIGHT = 500.0
  MAX_LINES     =   100

  @@lines = [] of Line
  @@animation_time = 0.0
  @@mouse_x = CANVAS_WIDTH / 2
  @@mouse_y = CANVAS_HEIGHT / 2

  def self.set_mouse_position(x : Float64, y : Float64)
    @@mouse_x = x
    @@mouse_y = y
  end

  def self.add_random_line
    # Use mouse position as center (with fallback to canvas center)
    center_x = @@mouse_x
    center_y = @@mouse_y

    # Ensure valid coordinates
    center_x = CANVAS_WIDTH / 2 if center_x.nil?
    center_y = CANVAS_HEIGHT / 2 if center_y.nil?

    # Random angle (0 to 2π)
    angle = rand * Math::PI * 2

    # Weighted random length (favor shorter lines)
    if rand < 0.7                 # 70% chance for short lines
      length = 10.0 + rand * 25.0 # Short lines: 10-35 pixels
    elsif rand < 0.9              # 20% chance for medium lines
      length = 35.0 + rand * 30.0 # Medium lines: 35-65 pixels
    else                          # 10% chance for long lines
      length = 65.0 + rand * 40.0 # Long lines: 65-105 pixels
    end

    # Calculate end point based on angle and length
    end_x = center_x + Math.cos(angle) * length
    end_y = center_y + Math.sin(angle) * length

    # Time-based gradient color
    time_factor = @@animation_time * 0.1
    hue = (time_factor + rand * 0.3) % 1.0 # Slowly changing hue with some randomness

    # Convert HSV to RGB for smooth color transitions
    color = hsv_to_rgb(hue, 0.8 + rand * 0.2, 0.9 + rand * 0.1)

    # Even thinner lines
    thickness = 0.3 + rand * 0.8

    # Longer life span for more lines on screen
    life = 4.0 + rand * 6.0 # Much longer: 4-10 seconds

    line = Line.new(center_x, center_y, end_x, end_y, color, thickness, life)
    @@lines << line

    # Remove old lines if too many
    if @@lines.size > MAX_LINES
      @@lines.shift
    end
  end

  # Convert HSV to RGB
  def self.hsv_to_rgb(h : Float64, s : Float64, v : Float64)
    h = h * 6.0
    i = h.floor.to_i
    f = h - i
    p = v * (1.0 - s)
    q = v * (1.0 - s * f)
    t = v * (1.0 - s * (1.0 - f))

    case i % 6
    when 0
      {r: v, g: t, b: p}
    when 1
      {r: q, g: v, b: p}
    when 2
      {r: p, g: v, b: t}
    when 3
      {r: p, g: q, b: v}
    when 4
      {r: t, g: p, b: v}
    else
      {r: v, g: p, b: q}
    end
  end

  def self.update_lines
    # Update existing lines
    @@lines.each(&.update)
    @@lines.reject!(&.alive?.!)

    # Add new lines automatically (reduced for stability)
    8.times do
      if rand < 0.8 # 80% chance each time
        add_random_line
      end
    end

    @@animation_time += 0.1
  end

  def self.clear_lines
    @@lines.clear
  end

  def self.lines
    @@lines
  end

  def self.animation_time
    @@animation_time
  end

  def self.line_count
    @@lines.size
  end
end

# Create and setup handler with GC protection
handler = UIng::Area::Handler.new
App.set_handler(handler)

handler.draw do |area, area_draw_params|
  ctx = area_draw_params.context

  # Draw animated background
  UIng::Area::Draw::Path.open(:winding) do |bg_path|
    bg_path.add_rectangle(0, 0, RandomLines::CANVAS_WIDTH, RandomLines::CANVAS_HEIGHT)
    bg_path.end_path

    # Animated background color
    time = RandomLines.animation_time
    bg_intensity = Math.sin(time * 0.1) * 0.02 + 0.05

    bg_brush = UIng::Area::Draw::Brush.new(
      :solid,
      bg_intensity * 0.5, # R
      bg_intensity * 0.5, # G
      bg_intensity * 2.0, # B
      1.0,                # A
    )

    ctx.fill(bg_path, bg_brush)
  end

  # Draw all lines with safe single-line approach
  RandomLines.lines.each do |line|
    # Create and draw single line safely
    UIng::Area::Draw::Path.open(:winding) do |line_path|
      line_path.new_figure(line.x1, line.y1)
      line_path.line_to(line.x2, line.y2)
      line_path.end_path

      # Line color with transparency for blending
      line_brush = UIng::Area::Draw::Brush.new(
        :solid,
        line.color[:r],
        line.color[:g],
        line.color[:b],
        line.alpha * 0.7, # Transparent for beautiful color mixing
      )

      ctx.stroke(line_path, line_brush,
        cap: :round,
        join: :round,
        thickness: line.thickness + 1.0,
        miter_limit: 10.0,
      )
    end
  end
end

area = UIng::Area.new(handler)
App.set_area(area)

# Mouse event handler (with GC protection)
handler.mouse_event do |area, mouse_event|
  mouse_data = mouse_event

  # Update mouse position for line generation
  RandomLines.set_mouse_position(mouse_data.x, mouse_data.y)

  case mouse_data.down
  when 1 # Left mouse button - add burst of lines from mouse position
    5.times { RandomLines.add_random_line }
  when 2 # Right mouse button - clear all lines
    RandomLines.clear_lines
  end

  # Update animation and queue redraw
  RandomLines.update_lines
  UIng::LibUI.area_queue_redraw_all(area)
end

handler.mouse_crossed { |_, _| }
handler.drag_broken { |_| }

# Simplified key event handler
handler.key_event do |area, key_event|
  key_data = key_event

  if key_data.up == 0 # Key pressed (not released)
    case key_data.key
    when 'c'.ord, 'C'.ord
      RandomLines.clear_lines
      UIng::LibUI.area_queue_redraw_all(area)
    end
  end

  true # Return 1 to indicate the key event was handled
end

main_window = UIng::Window.new("Random Lines Animation", 600, 500)
App.set_main_window(main_window)

# Create info label
info_label = UIng::Label.new("🎨 Click=Draw Line | C=Clear")

box = UIng::Box.new(:vertical)
box.padded = true
box.append(info_label, false)
box.append(App.area, true)

App.main_window.child = box
App.main_window.margined = true

App.main_window.on_closing do
  UIng.quit
  true
end

App.main_window.show

# Event-driven animation (no timer needed)

UIng.main
UIng.uninit
