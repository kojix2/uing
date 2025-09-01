require "uing"
require "chipmunk"

PX_PER_M = 32.0
WIN_W    = 600
WIN_H    =  400
DT       = 1.0/120.0

def to_px(v : CP::Vect) : {Float64, Float64}
  {v.x * PX_PER_M, WIN_H - v.y * PX_PER_M} # Flip Y because screen Y+ is downward
end

# Collision types
COLL_GROUND = 1
COLL_PLAYER = 2

# Main game class
class Game
  getter space : CP::Space
  getter! player_body : CP::Body
  @player_body : CP::Body
  @segments = [] of {CP::Vect, CP::Vect}

  def initialize
    @space = CP::Space.new
    @space.gravity = CP.v(0, -9.8)
    @space.iterations = 10
    build_terrain
    @player_body = build_player
  end

  # Generate gentle zigzag planks as segments
  def build_terrain
    sb = @space.static_body
    @segments.clear

    width_m = WIN_W / PX_PER_M
    height_m = WIN_H / PX_PER_M
    margin_x = 1.0
    top_y = height_m - 1.2
    levels = 6
    len = (width_m - margin_x * 2) * 0.55
    vertical_gap = (height_m - 3.0) / (levels + 1)
    slope_drop = 3

    # Side walls and floor
    add_segment(sb, CP.v(margin_x * 0.2, 0.8), CP.v(margin_x * 0.2, height_m - 0.5))
    add_segment(sb, CP.v(width_m - margin_x * 0.2, 0.8), CP.v(width_m - margin_x * 0.2, height_m - 0.5))
    add_segment(sb, CP.v(margin_x * 0.2, 0.8), CP.v(width_m - margin_x * 0.2, 0.8))

    levels.times do |i|
      y = top_y - i * vertical_gap
      if i.even?
        x0 = margin_x
        x1 = (margin_x + len).clamp(margin_x, width_m - margin_x)
        y0 = y
        y1 = (y - slope_drop).clamp(0.8, height_m - 0.5)
      else
        x1 = width_m - margin_x
        x0 = (x1 - len).clamp(margin_x, width_m - margin_x)
        y1 = y
        y0 = (y - slope_drop).clamp(0.8, height_m - 0.5)
      end
      add_segment(sb, CP.v(x0, y0), CP.v(x1, y1))
    end
  end

  # Player is a single circle (simple model)
  def build_player : CP::Body
    mass = 70.0
    radius = 0.30
    moment = CP::Shape::Circle.moment(mass, 0.0, radius, CP.v(0, 0))
    body = CP::Body.new(mass, moment)
    # Start above the first plank on the left
    start_x = 1.2
    start_y = (WIN_H / PX_PER_M) - 1.0
    body.position = CP.v(start_x, start_y)
    @space.add body
    shape = CP::Shape::Circle.new(body, radius, CP.v(0, 0))
    shape.friction = 0.95
    shape.elasticity = 1.0
    shape.collision_type = COLL_PLAYER
    @space.add shape
    body
  end

  # Restart (R key)
  def reset!
    # Recreate space for a clean state
    @space = CP::Space.new
    @space.gravity = CP.v(0, -9.8)
    @space.iterations = 10
    build_terrain
    @player_body = build_player
  end

  # Step physics (twice per frame for ~60FPS)
  def update
    2.times { @space.step(DT) }
  end

  # Segments for drawing
  def terrain_segments : Array({CP::Vect, CP::Vect})
    @segments
  end

  private def add_segment(sb : CP::Body, a : CP::Vect, b : CP::Vect)
    seg = CP::Shape::Segment.new(sb, a, b, 0.05)
    seg.friction = 1.1
    seg.elasticity = 0.6
    seg.collision_type = COLL_GROUND
    @space.add seg
    @segments << {a, b}
  end
end

UIng.init
game = Game.new

window = UIng::Window.new("ZigZag (Chipmunk)", WIN_W, WIN_H, menubar: false)
box = UIng::Box.new(:vertical)
label = UIng::Label.new("Press [R] to reset")

# Area handler: drawing and key input
handler = UIng::Area::Handler.new do
  draw do |area, params|
    ctx = params.context
    bg = UIng::Area::Draw::Brush.new(:solid, 0.96, 0.98, 1.0, 1.0)
    ctx.fill_path(bg) { |p| p.add_rectangle(0, 0, WIN_W, WIN_H) }
    line = UIng::Area::Draw::Brush.new(:solid, 0.0, 0.0, 0.0, 1.0)
    game.terrain_segments.each do |(a, b)|
      x0, y0 = to_px(a)
      x1, y1 = to_px(b)
      ctx.stroke_path(line, thickness: 3.0) do |path|
        path.new_figure(x0, y0)
        path.line_to(x1, y1)
      end
    end
    pos = game.player_body.position
    x, y = to_px(pos)
    player = UIng::Area::Draw::Brush.new(:solid, 0.2, 0.2, 0.2, 1.0)
    ctx.fill_path(player) do |path|
      path.new_figure_with_arc(x, y, 0.30 * PX_PER_M, 0, Math::PI * 2, false)
    end
    label.text = "Press [R] to reset"
  end
  key_event do |area, event|
    # Ignore key repeat (only handle key down)
    next true if event.up != 0
    case event.key
    when 'r', 'R'
      game.reset!
      area.queue_redraw_all
      true
    else
      false
    end
  end
end
area = UIng::Area.new(handler, WIN_W, WIN_H - 40)

box.append(area, stretchy: true)
box.append(label, stretchy: false)
window.child = box

UIng.timer(8) do
  game.update
  area.queue_redraw_all
  1
end

window.on_closing { UIng.quit; true }
window.show
UIng.main
