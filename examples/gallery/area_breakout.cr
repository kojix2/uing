require "../../src/uing"

# Game configuration
module Config
  SCREEN_W = 800.0
  SCREEN_H = 600.0
  FPS      =    30
  DT       = 1.0 / FPS
  DEBUG    = false

  PADDLE_W     = 100.0
  PADDLE_H     =  15.0
  PADDLE_SPEED =  12.0

  BALL_RADIUS               =  8.0
  BALL_SPEED                =  8.0
  BALL_MIN_BOUNCE_ANGLE_DEG = 15.0

  COLORS = [
    {r: 0.8, g: 0.2, b: 0.2},
    {r: 0.8, g: 0.6, b: 0.2},
    {r: 0.8, g: 0.8, b: 0.2},
    {r: 0.2, g: 0.8, b: 0.2},
    {r: 0.2, g: 0.2, b: 0.8},
  ]
end

enum GameState
  Waiting
  Playing
  GameOver
  Won
end

alias Bounds = NamedTuple(x: Float64, y: Float64, width: Float64, height: Float64)

# Player paddle
struct Paddle
  property x : Float64, y : Float64, width : Float64, height : Float64, speed : Float64

  def initialize(@x : Float64, @y : Float64, @width : Float64 = Config::PADDLE_W, @height : Float64 = Config::PADDLE_H)
    @speed = Config::PADDLE_SPEED
  end

  def move_left(screen_width : Float64)
    @x = (@x - @speed).clamp(0.0, screen_width - @width)
    puts "Paddle left x=#{@x}" if Config::DEBUG
  end

  def move_right(screen_width : Float64)
    @x = (@x + @speed).clamp(0.0, screen_width - @width)
    puts "Paddle right x=#{@x}" if Config::DEBUG
  end

  def set_position(mouse_x : Float64, screen_width : Float64)
    @x = (mouse_x - @width / 2).clamp(0.0, screen_width - @width)
  end

  def bounds : Bounds
    {x: @x, y: @y, width: @width, height: @height}
  end
end

# Bouncing ball
struct Ball
  property x : Float64, y : Float64, velocity_x : Float64, velocity_y : Float64, radius : Float64, active : Bool

  def initialize(@x : Float64, @y : Float64, @radius : Float64 = Config::BALL_RADIUS)
    @velocity_x = 0.0
    @velocity_y = -Config::BALL_SPEED
    @active = false
  end

  def update
    return unless @active
    @x += @velocity_x
    @y += @velocity_y
  end

  def start
    @active = true

    # Generate random angle between -45 and +45 degrees
    angle_deg = (rand - 0.5) * 90.0 # -45 to +45 degrees
    angle_rad = angle_deg * Math::PI / 180.0

    # Set velocity components based on random angle
    speed = Config::BALL_SPEED
    @velocity_x = speed * Math.sin(angle_rad)
    @velocity_y = -speed * Math.cos(angle_rad) # Negative to go upward

    puts "Ball start angle=#{angle_deg.round(1)}°, vx=#{@velocity_x.round(2)}, vy=#{@velocity_y.round(2)}" if Config::DEBUG
  end

  def reset(start_x : Float64, start_y : Float64)
    @x = start_x
    @y = start_y
    @velocity_x = 0.0
    @velocity_y = -Config::BALL_SPEED
    @active = false
    puts "Ball reset x=#{@x}, y=#{@y}" if Config::DEBUG
  end

  def normalize_speed(total_speed = Config::BALL_SPEED)
    mag = Math.sqrt(@velocity_x * @velocity_x + @velocity_y * @velocity_y)
    return if mag == 0.0
    scale = total_speed / mag
    @velocity_x *= scale
    @velocity_y *= scale
  end

  def handle_wall_collision(screen_width : Float64, screen_height : Float64)
    return unless @active

    if @x - @radius <= 0.0
      @x = @radius
      @velocity_x = @velocity_x.abs
      puts "Wall L" if Config::DEBUG
    elsif @x + @radius >= screen_width
      @x = screen_width - @radius
      @velocity_x = -@velocity_x.abs
      puts "Wall R" if Config::DEBUG
    end

    if @y - @radius <= 0.0
      @y = @radius
      @velocity_y = @velocity_y.abs
      puts "Wall T" if Config::DEBUG
    end
  end

  def below_screen?(screen_height : Float64)
    @y > screen_height + @radius
  end

  def bounds : Bounds
    {x: @x - @radius, y: @y - @radius, width: @radius * 2, height: @radius * 2}
  end
end

# Destructible block
struct Block
  property x : Float64, y : Float64, width : Float64, height : Float64, active : Bool, color : NamedTuple(r: Float64, g: Float64, b: Float64)

  def initialize(@x : Float64, @y : Float64, @width : Float64 = 80.0, @height : Float64 = 30.0, @color = {r: 0.8, g: 0.2, b: 0.2})
    @active = true
  end

  def destroy
    @active = false
    puts "Block destroyed x=#{@x}, y=#{@y}" if Config::DEBUG
  end

  def bounds : Bounds
    {x: @x, y: @y, width: @width, height: @height}
  end
end

# Main game logic
class BreakoutGame
  property paddle : Paddle
  property ball : Ball
  property blocks : Array(Block)
  property score : Int32
  property lives : Int32
  property game_state : GameState
  property screen_width : Float64
  property screen_height : Float64

  def initialize(@screen_width : Float64 = Config::SCREEN_W, @screen_height : Float64 = Config::SCREEN_H)
    paddle_x = @screen_width / 2 - Config::PADDLE_W / 2
    paddle_y = @screen_height - 50.0
    @paddle = Paddle.new(paddle_x, paddle_y)

    ball_x = @screen_width / 2
    ball_y = paddle_y - 20.0
    @ball = Ball.new(ball_x, ball_y)

    @blocks = [] of Block
    @score = 0
    @lives = 3
    @game_state = GameState::Waiting

    create_blocks
    puts "Game init #{@screen_width}x#{@screen_height}" if Config::DEBUG
  end

  def create_blocks
    @blocks.clear
    block_width = 75.0 # Reduced from 80.0 to create horizontal gaps
    block_height = 30.0
    block_spacing = 5.0 # Gap between blocks horizontally
    blocks_per_row = 8
    rows = 5
    total_width = blocks_per_row * block_width + (blocks_per_row - 1) * block_spacing
    start_x = (@screen_width - total_width) / 2.0
    start_y = 80.0

    rows.times do |row|
      color = Config::COLORS[row]? || Config::COLORS.last
      blocks_per_row.times do |col|
        x = start_x + col * (block_width + block_spacing)
        y = start_y + row * (block_height + 5.0)
        @blocks << Block.new(x, y, block_width, block_height, color)
      end
    end
    puts "Blocks: #{@blocks.size}" if Config::DEBUG
  end

  def start_game
    @game_state = GameState::Playing
    @ball.start
  end

  def reset_game
    @score = 0
    @lives = 3
    @game_state = GameState::Waiting

    @paddle.x = @screen_width / 2 - @paddle.width / 2
    ball_x = @screen_width / 2
    ball_y = @paddle.y - 20.0
    @ball.reset(ball_x, ball_y)

    create_blocks
  end

  def update
    return unless @game_state == GameState::Playing

    @ball.update
    @ball.handle_wall_collision(@screen_width, @screen_height)

    check_ball_paddle_collision
    check_ball_block_collisions

    if @ball.below_screen?(@screen_height)
      @lives -= 1
      if @lives <= 0
        @game_state = GameState::GameOver
      else
        ball_x = @screen_width / 2
        ball_y = @paddle.y - 20.0
        @ball.reset(ball_x, ball_y)
        @game_state = GameState::Waiting
      end
    end

    if @blocks.none?(&.active)
      @game_state = GameState::Won
    end
  end

  def rectangles_intersect?(rect1, rect2)
    rect1[:x] < rect2[:x] + rect2[:width] &&
      rect1[:x] + rect1[:width] > rect2[:x] &&
      rect1[:y] < rect2[:y] + rect2[:height] &&
      rect1[:y] + rect1[:height] > rect2[:y]
  end

  # Paddle reflection with angle control
  def check_ball_paddle_collision
    return unless @ball.active

    if rectangles_intersect?(@ball.bounds, @paddle.bounds)
      @ball.y = @paddle.y - @ball.radius - 0.1

      hit_pos = (@ball.x - @paddle.x) / @paddle.width
      hit_pos = [[hit_pos, 1.0].min, 0.0].max
      t = (hit_pos - 0.5) * 2.0

      min_deg = Config::BALL_MIN_BOUNCE_ANGLE_DEG
      max_deg = 90.0 - min_deg
      angle_deg = t * max_deg
      angle_rad = angle_deg * Math::PI / 180.0

      speed = Config::BALL_SPEED
      @ball.velocity_x = speed * Math.sin(angle_rad)
      @ball.velocity_y = -speed * Math.cos(angle_rad)

      @ball.normalize_speed
      puts "Paddle bounce t=#{t}, vx=#{@ball.velocity_x}, vy=#{@ball.velocity_y}" if Config::DEBUG
    end
  end

  # Block collision with overlap detection
  def check_ball_block_collisions
    return unless @ball.active

    ball = @ball.bounds
    bx1 = ball[:x]; by1 = ball[:y]
    bx2 = bx1 + ball[:width]; by2 = by1 + ball[:height]

    @blocks.each_with_index do |block, index|
      next unless block.active
      r = block.bounds
      rx1 = r[:x]; ry1 = r[:y]
      rx2 = rx1 + r[:width]; ry2 = ry1 + r[:height]

      next unless rectangles_intersect?(ball, r)

      overlap_left = bx2 - rx1
      overlap_right = rx2 - bx1
      overlap_top = by2 - ry1
      overlap_bottom = ry2 - by1

      min_x = Math.min(overlap_left, overlap_right)
      min_y = Math.min(overlap_top, overlap_bottom)

      if min_x < min_y
        @ball.velocity_x = -@ball.velocity_x
        if overlap_left < overlap_right
          @ball.x = rx1 - @ball.radius
        else
          @ball.x = rx2 + @ball.radius
        end
      else
        @ball.velocity_y = -@ball.velocity_y
        if overlap_top < overlap_bottom
          @ball.y = ry1 - @ball.radius
        else
          @ball.y = ry2 + @ball.radius
        end
      end

      @ball.normalize_speed

      # ★ ここが重要：structの変更を配列へ書き戻す
      block.destroy
      @blocks[index] = block

      @score += 10
      puts "Block destroyed at index #{index}, score: #{@score}" if Config::DEBUG
      break
    end
  end

  def handle_mouse_move(x : Float64, y : Float64)
    @paddle.set_position(x, @screen_width)
    if @game_state == GameState::Waiting && !@ball.active
      @ball.x = @paddle.x + @paddle.width / 2.0
      @ball.y = @paddle.y - 20.0
    end
  end

  def handle_mouse_click
    case @game_state
    when GameState::Waiting
      start_game
    when GameState::GameOver, GameState::Won
      reset_game
    end
  end

  def handle_key_input(key : Char, up : Int32)
    return if up != 0

    case key
    when ' '
      case @game_state
      when GameState::Waiting
        start_game
      when GameState::GameOver, GameState::Won
        reset_game
      end
    when 'a', 'A'
      @paddle.move_left(@screen_width)
      update_ball_position_if_waiting
    when 'd', 'D'
      @paddle.move_right(@screen_width)
      update_ball_position_if_waiting
    end
  end

  def handle_extended_key(ext_key : UIng::Area::ExtKey, up : Int32)
    return if up != 0
    case ext_key
    when UIng::Area::ExtKey::Left
      @paddle.move_left(@screen_width)
      update_ball_position_if_waiting
    when UIng::Area::ExtKey::Right
      @paddle.move_right(@screen_width)
      update_ball_position_if_waiting
    end
  end

  private def update_ball_position_if_waiting
    if @game_state == GameState::Waiting && !@ball.active
      @ball.x = @paddle.x + @paddle.width / 2.0
      @ball.y = @paddle.y - 20.0
    end
  end
end

UIng.init

# Text display setup
DEFAULT_FONT = UIng::FontDescriptor.new(
  family: "Arial",
  size: 16,
  weight: :bold,
  italic: :normal,
  stretch: :normal
)

WAITING_TEXT = UIng::Area::AttributedString.new("PRESS SPACE or CLICK to start")
WAITING_TEXT.set_attribute(UIng::Area::Attribute.new_color(1.0, 1.0, 1.0, 1.0), 0, WAITING_TEXT.len)

GAME_OVER_TEXT = UIng::Area::AttributedString.new("GAME OVER - PRESS SPACE or CLICK to restart")
GAME_OVER_TEXT.set_attribute(UIng::Area::Attribute.new_color(1.0, 1.0, 1.0, 1.0), 0, GAME_OVER_TEXT.len)

WON_TEXT = UIng::Area::AttributedString.new("CONGRATULATIONS! - PRESS SPACE or CLICK to play again")
WON_TEXT.set_attribute(UIng::Area::Attribute.new_color(1.0, 1.0, 1.0, 1.0), 0, WON_TEXT.len)

CONTROLS_TEXT = UIng::Area::AttributedString.new("Mouse: move paddle, A/D or ←/→: nudge paddle")
CONTROLS_TEXT.set_attribute(UIng::Area::Attribute.new_color(1.0, 1.0, 1.0, 1.0), 0, CONTROLS_TEXT.len)

GAME    = BreakoutGame.new
HANDLER = UIng::Area::Handler.new

HANDLER.draw do |area, params|
  ctx = params.context

  bg = UIng::Area::Draw::Brush.new(:solid, 0.1, 0.1, 0.2, 1.0)
  ctx.fill_path(bg) { |p| p.add_rectangle(0, 0, GAME.screen_width, GAME.screen_height) }

  GAME.blocks.each do |block|
    next unless block.active
    b = UIng::Area::Draw::Brush.new(:solid, block.color[:r], block.color[:g], block.color[:b], 1.0)
    ctx.fill_path(b) { |p| p.add_rectangle(block.x, block.y, block.width, block.height) }
  end

  pb = UIng::Area::Draw::Brush.new(:solid, 0.8, 0.8, 0.8, 1.0)
  ctx.fill_path(pb) { |p| p.add_rectangle(GAME.paddle.x, GAME.paddle.y, GAME.paddle.width, GAME.paddle.height) }

  bb = UIng::Area::Draw::Brush.new(:solid, 1.0, 1.0, 1.0, 1.0)
  ctx.fill_path(bb) { |p| p.new_figure_with_arc(GAME.ball.x, GAME.ball.y, GAME.ball.radius, 0, Math::PI * 2, false) }

  # Draw text based on game state
  case GAME.game_state
  when GameState::Waiting
    UIng::Area::Draw::TextLayout.open(
      string: WAITING_TEXT,
      default_font: DEFAULT_FONT,
      width: GAME.screen_width,
      align: UIng::Area::Draw::TextAlign::Center
    ) do |text_layout|
      ctx.draw_text_layout(text_layout, 0, GAME.screen_height / 2 - 50)
    end

    UIng::Area::Draw::TextLayout.open(
      string: CONTROLS_TEXT,
      default_font: DEFAULT_FONT,
      width: GAME.screen_width,
      align: UIng::Area::Draw::TextAlign::Center
    ) do |text_layout|
      ctx.draw_text_layout(text_layout, 0, GAME.screen_height / 2 + 20)
    end
  when GameState::GameOver
    UIng::Area::Draw::TextLayout.open(
      string: GAME_OVER_TEXT,
      default_font: DEFAULT_FONT,
      width: GAME.screen_width,
      align: UIng::Area::Draw::TextAlign::Center
    ) do |text_layout|
      ctx.draw_text_layout(text_layout, 0, GAME.screen_height / 2 - 10)
    end
  when GameState::Won
    UIng::Area::Draw::TextLayout.open(
      string: WON_TEXT,
      default_font: DEFAULT_FONT,
      width: GAME.screen_width,
      align: UIng::Area::Draw::TextAlign::Center
    ) do |text_layout|
      ctx.draw_text_layout(text_layout, 0, GAME.screen_height / 2 - 10)
    end
  end
end

HANDLER.mouse_event do |area, event|
  if (event.down != 0 || event.up != 0) && Config::DEBUG
    puts "Mouse x=#{event.x}, y=#{event.y}, down=#{event.down}, up=#{event.up}"
  end
  GAME.handle_mouse_move(event.x, event.y)

  # Handle mouse click (button down event)
  if event.down != 0
    GAME.handle_mouse_click
    area.queue_redraw_all
  end

  true
end

HANDLER.key_event do |area, event|
  if event.key != '\0'
    GAME.handle_key_input(event.key, event.up)
  end
  if event.ext_key != UIng::Area::ExtKey::N0
    GAME.handle_extended_key(event.ext_key, event.up)
  end
  area.queue_redraw_all
  true
end

AREA = UIng::Area.new(HANDLER)
vbox = UIng::Box.new(:vertical, padded: true)
vbox.append(AREA, true)

WINDOW = UIng::Window.new("Breakout Game", GAME.screen_width.to_i, GAME.screen_height.to_i) do
  on_closing do
    # Free AttributedString objects to prevent memory leaks
    WAITING_TEXT.free
    GAME_OVER_TEXT.free
    WON_TEXT.free
    CONTROLS_TEXT.free
    UIng.quit
    true
  end
  show
end

WINDOW.child = vbox

UIng.timer((1000.0 / Config::FPS).to_i) do
  GAME.update
  AREA.queue_redraw_all
  1
end

UIng.main
UIng.uninit
