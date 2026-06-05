class AirHockey3DGame
  property player : AirHockey3DMallet
  property opponent : AirHockey3DMallet
  property puck : AirHockey3DPuck
  property player_score : Int32
  property opponent_score : Int32
  property state : AirHockey3DState
  property screen_width : Float64
  property screen_height : Float64
  property message : String

  getter table_width : Float64 = AirHockey3DConfig::TABLE_W
  getter table_depth : Float64 = AirHockey3DConfig::TABLE_D
  getter goal_width : Float64 = AirHockey3DConfig::GOAL_W

  def initialize(@screen_width : Float64 = AirHockey3DConfig::SCREEN_W, @screen_height : Float64 = AirHockey3DConfig::SCREEN_H)
    @player = AirHockey3DMallet.new(Vec2.new(0.0, @table_depth / 2.0 - 78.0))
    @opponent = AirHockey3DMallet.new(Vec2.new(0.0, -@table_depth / 2.0 + 78.0))
    @puck = AirHockey3DPuck.new(Vec2.new(0.0, 0.0))
    @player_score = 0
    @opponent_score = 0
    @state = AirHockey3DState::Serving
    @message = "CLICK or SPACE to serve"
    @point_timer = 0
    @sound_events = [] of AirHockey3DSoundEvent
  end

  # One simulation tick. The order matters:
  # 1. Move the computer mallet.
  # 2. Move and constrain the puck.
  # 3. Resolve mallet collisions.
  # 4. Re-apply rails because collisions can push the puck into a wall.
  # 5. Check for goals.
  def update
    case @state
    when AirHockey3DState::Playing
      update_opponent
      update_puck
      collide_with_mallet(@player)
      collide_with_mallet(@opponent)
      settle_puck_after_collisions
      check_score
    when AirHockey3DState::Point
      @point_timer -= 1
      reset_after_point if @point_timer <= 0
    end
  end

  # The timer loop calls this once per frame and forwards the result to audio.
  # Returning a copy keeps the simulation free to queue more events next tick.
  def drain_sound_events : Array(AirHockey3DSoundEvent)
    events = @sound_events.dup
    @sound_events.clear
    events
  end

  # Mouse coordinates arrive in screen space, so convert them back to table
  # space before moving the player's mallet.
  def handle_mouse(x : Float64, y : Float64)
    world = screen_to_world(x, y)
    @player.move_to(world, 42.0, player_x_limit, player_z_min, player_z_max)
  end

  # Serve starts a point; after the match is finished, the same action restarts.
  def serve
    case @state
    when AirHockey3DState::Serving
      direction = @player_score <= @opponent_score ? -1.0 : 1.0
      @puck.position = Vec2.new(0.0, 0.0)
      @puck.velocity = Vec2.new((rand - 0.5) * 5.0, direction * 10.5)
      @state = AirHockey3DState::Playing
      @message = ""
      queue_sound(AirHockey3DSoundEvent::Serve)
    when AirHockey3DState::Finished
      reset_match
    end
  end

  def reset_match
    @player_score = 0
    @opponent_score = 0
    reset_positions(0.0)
    @puck.velocity = Vec2.new(0.0, 0.0)
    @state = AirHockey3DState::Serving
    @message = "CLICK or SPACE to serve"
  end

  def nudge_player(dx : Float64, dz : Float64)
    target = @player.position + Vec2.new(dx, dz)
    @player.move_to(target, 30.0, player_x_limit, player_z_min, player_z_max)
  end

  # Project a point on the table plane into screen coordinates. This is a simple
  # one-point perspective approximation: x scale grows toward the near rail, and
  # z is mapped through the same projective transform so the center line lands at
  # the perspective-correct midpoint.
  def project(point : Vec2) : NamedTuple(x: Float64, y: Float64, scale: Float64)
    t = ((point.z + @table_depth / 2.0) / @table_depth).clamp(0.0, 1.0)
    screen_t = perspective_t(t)
    table_px_w = projected_table_width
    top = @screen_height * 0.12
    bottom = [@screen_height * 0.91, top + 1.0].max
    scale = perspective_scale(t)
    x = @screen_width / 2.0 + point.x * (table_px_w / @table_width) * scale
    y = top + (bottom - top) * screen_t
    {x: x, y: y, scale: scale}
  end

  # Inverse of #project for mouse input. Keeping this paired with project avoids
  # the common bug where drawing and hit-testing drift apart.
  def screen_to_world(x : Float64, y : Float64) : Vec2
    top = @screen_height * 0.12
    bottom = [@screen_height * 0.91, top + 1.0].max
    screen_t = ((y - top) / (bottom - top)).clamp(0.0, 1.0)
    t = inverse_perspective_t(screen_t)
    z = -@table_depth / 2.0 + t * @table_depth
    scale = perspective_scale(t)
    table_px_w = projected_table_width
    world_x = (x - @screen_width / 2.0) / ((table_px_w / @table_width) * scale)
    Vec2.new(world_x, z)
  end

  private def perspective_t(t : Float64) : Float64
    c = perspective_c
    ((1.0 + c) * t) / (1.0 + c * t)
  end

  private def inverse_perspective_t(screen_t : Float64) : Float64
    c = perspective_c
    screen_t / (1.0 + c - c * screen_t)
  end

  private def perspective_scale(t : Float64) : Float64
    AirHockey3DConfig::FAR_SCALE / (1.0 + perspective_c * t)
  end

  private def perspective_c : Float64
    # Projective mapping for the table plane. This keeps the rail edges straight
    # while placing equal world-depth intervals closer together in the distance.
    AirHockey3DConfig::FAR_SCALE / AirHockey3DConfig::NEAR_SCALE - 1.0
  end

  private def projected_table_width : Float64
    # libui may briefly report tiny Area sizes during window creation/resizing.
    # Keep the projection denominator positive so mouse input cannot produce NaN.
    [[@screen_width * 0.72, 780.0].min, 1.0].max
  end

  private def queue_sound(event : AirHockey3DSoundEvent)
    @sound_events << event
  end

  private def player_x_limit : Float64
    [@table_width / 2.0 - @player.radius - 8.0, 0.0].max
  end

  private def player_z_min : Float64
    18.0
  end

  private def player_z_max : Float64
    [@table_depth / 2.0 - @player.radius - 18.0, player_z_min].max
  end

  private def update_opponent
    target = opponent_target
    max_step = loose_puck_on_opponent_side? ? AirHockey3DConfig::OPPONENT_ATTACK_STEP : AirHockey3DConfig::OPPONENT_GUARD_STEP
    @opponent.move_to(target, max_step, opponent_x_limit, opponent_z_min, opponent_z_max)
  end

  private def opponent_target : Vec2
    return opponent_attack_target if loose_puck_on_opponent_side?

    target_z = -@table_depth / 2.0 + 90.0
    target_x = @puck.position.z < 70.0 ? @puck.position.x * 0.86 : 0.0
    if @puck.position.z < -80.0 && @puck.velocity.z < 0.0
      target_z = @puck.position.z + 22.0
    end

    Vec2.new(target_x, target_z)
  end

  private def opponent_attack_target : Vec2
    # A slow sideways puck in the upper half should be played, not watched.
    # Aim just behind it so the mallet crosses through and sends it back down-table.
    target_x = @puck.position.x
    target_z = @puck.position.z - @opponent.radius * 0.85
    Vec2.new(target_x, target_z)
  end

  private def loose_puck_on_opponent_side? : Bool
    return false unless @puck.position.z < -35.0

    @puck.speed < AirHockey3DConfig::LOOSE_PUCK_SPEED ||
      @puck.velocity.z.abs < AirHockey3DConfig::LATERAL_PUCK_Z_SPEED
  end

  private def opponent_x_limit : Float64
    [@table_width / 2.0 - @opponent.radius - 8.0, 0.0].max
  end

  private def opponent_z_min : Float64
    -@table_depth / 2.0 + @opponent.radius + 18.0
  end

  private def opponent_z_max : Float64
    [opponent_z_min, -18.0].max
  end

  # The puck update intentionally stays small: integrate position, apply friction,
  # clamp extreme speeds, then bounce against the rails.
  private def update_puck
    @puck.position += @puck.velocity
    @puck.velocity *= 0.992

    if @puck.speed < AirHockey3DConfig::SLEEP_SPEED
      @puck.velocity = Vec2.new(0.0, 0.0)
    elsif @puck.speed > 20.0
      @puck.velocity = @puck.velocity.limit(20.0)
    end

    bounce_side_walls
    bounce_end_walls
    bounce_rounded_corners
  end

  private def bounce_end_walls
    z_limit = @table_depth / 2.0 - @puck.radius
    in_goal = @puck.position.x.abs < @goal_width / 2.0

    # The mouth of each goal is open. Everywhere else, the end rail bounces.
    if @puck.position.z < -z_limit && !in_goal
      @puck.position = Vec2.new(@puck.position.x, -z_limit)
      @puck.velocity = Vec2.new(@puck.velocity.x, @puck.velocity.z.abs)
      queue_sound(AirHockey3DSoundEvent::RailHit)
    elsif @puck.position.z > z_limit && !in_goal
      @puck.position = Vec2.new(@puck.position.x, z_limit)
      @puck.velocity = Vec2.new(@puck.velocity.x, -@puck.velocity.z.abs)
      queue_sound(AirHockey3DSoundEvent::RailHit)
    end
  end

  private def settle_puck_after_collisions
    bounce_side_walls
    bounce_end_walls
    bounce_rounded_corners
  end

  private def bounce_side_walls
    x_limit = @table_width / 2.0 - @puck.radius
    if @puck.position.x < -x_limit
      @puck.position = Vec2.new(-x_limit, @puck.position.z)
      @puck.velocity = Vec2.new(@puck.velocity.x.abs, @puck.velocity.z)
      queue_sound(AirHockey3DSoundEvent::RailHit)
    elsif @puck.position.x > x_limit
      @puck.position = Vec2.new(x_limit, @puck.position.z)
      @puck.velocity = Vec2.new(-@puck.velocity.x.abs, @puck.velocity.z)
      queue_sound(AirHockey3DSoundEvent::RailHit)
    end
  end

  private def bounce_rounded_corners
    corner_radius = AirHockey3DConfig::CORNER_R
    x_limit = @table_width / 2.0 - @puck.radius
    z_limit = @table_depth / 2.0 - @puck.radius
    corner_x = x_limit - corner_radius
    corner_z = z_limit - corner_radius

    [-1.0, 1.0].each do |x_side|
      [-1.0, 1.0].each do |z_side|
        next unless @puck.position.x * x_side > corner_x
        next unless @puck.position.z * z_side > corner_z
        next if @puck.position.x.abs < @goal_width / 2.0

        center = Vec2.new(x_side * corner_x, z_side * corner_z)
        offset = @puck.position - center
        distance = offset.length
        next unless distance > corner_radius

        normal = offset.normalized
        @puck.position = center + normal * corner_radius
        incoming = @puck.velocity.dot(normal)
        @puck.velocity -= normal * (2.0 * incoming) if incoming > 0.0
        queue_sound(AirHockey3DSoundEvent::RailHit)
      end
    end
  end

  # Disc-vs-disc collision: separate overlap first, then reflect any velocity
  # moving into the mallet and add a little impulse from mallet motion.
  private def collide_with_mallet(mallet : AirHockey3DMallet)
    delta = @puck.position - mallet.position
    distance = delta.length
    min_distance = @puck.radius + mallet.radius
    return if distance >= min_distance

    normal = collision_normal(delta, mallet)
    return if normal.length <= AirHockey3DConfig::EPSILON

    overlap = min_distance - distance
    @puck.position += normal * (overlap + 0.2)

    incoming = @puck.velocity.dot(normal)
    reflected = incoming < 0.0 ? @puck.velocity - normal * (2.0 * incoming) : @puck.velocity
    impulse = mallet.velocity * 0.72 + normal * 2.3
    @puck.velocity = (reflected * 0.72 + impulse).limit(21.0)
    queue_sound(AirHockey3DSoundEvent::MalletHit)
  end

  private def collision_normal(delta : Vec2, mallet : AirHockey3DMallet) : Vec2
    # If two discs are almost perfectly centered, derive a stable direction from
    # motion. Without this fallback, a rare exact overlap would never separate.
    return delta.normalized if delta.length > AirHockey3DConfig::EPSILON

    relative_motion = @puck.velocity - mallet.velocity
    return relative_motion.normalized if relative_motion.length > AirHockey3DConfig::EPSILON

    Vec2.new(0.0, @puck.position.z >= 0.0 ? 1.0 : -1.0)
  end

  private def check_score
    return unless @puck.position.z.abs > @table_depth / 2.0 + @puck.radius
    return unless @puck.position.x.abs < @goal_width / 2.0

    if @puck.position.z < 0
      @player_score += 1
      @message = "GOAL FOR YOU"
    else
      @opponent_score += 1
      @message = "OPPONENT SCORES"
    end

    if @player_score >= AirHockey3DConfig::WINNING_SCORE || @opponent_score >= AirHockey3DConfig::WINNING_SCORE
      @state = AirHockey3DState::Finished
      @message = @player_score > @opponent_score ? "YOU WIN - CLICK or SPACE" : "GAME OVER - CLICK or SPACE"
      queue_sound(AirHockey3DSoundEvent::MatchOver)
    else
      @state = AirHockey3DState::Point
      @point_timer = 70
      queue_sound(AirHockey3DSoundEvent::Goal)
    end
  end

  private def reset_after_point
    reset_positions(0.0)
    @puck.velocity = Vec2.new(0.0, 0.0)
    @state = AirHockey3DState::Serving
    @message = "CLICK or SPACE to serve"
  end

  # Reset both positions and previous positions so the next collision does not
  # inherit a stale velocity from the previous point.
  private def reset_positions(puck_z : Float64)
    @player.position = Vec2.new(0.0, @table_depth / 2.0 - 78.0)
    @player.previous = @player.position
    @player.velocity = Vec2.new(0.0, 0.0)
    @opponent.position = Vec2.new(0.0, -@table_depth / 2.0 + 78.0)
    @opponent.previous = @opponent.position
    @opponent.velocity = Vec2.new(0.0, 0.0)
    @puck.position = Vec2.new(0.0, puck_z)
  end
end
