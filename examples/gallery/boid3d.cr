require "../../src/uing"

DEFAULT_BOID_COUNT = 400

# 3D Vector utility class
struct Vec3
  property x : Float64
  property y : Float64
  property z : Float64

  def initialize(@x : Float64, @y : Float64, @z : Float64)
  end

  def +(other : Vec3)
    Vec3.new(@x + other.x, @y + other.y, @z + other.z)
  end

  def -(other : Vec3)
    Vec3.new(@x - other.x, @y - other.y, @z - other.z)
  end

  def *(other : Float64)
    Vec3.new(@x * other, @y * other, @z * other)
  end

  def /(other : Float64)
    Vec3.new(@x / other, @y / other, @z / other)
  end

  def magnitude
    Math.sqrt(@x * @x + @y * @y + @z * @z)
  end

  def normalize
    mag = magnitude
    return Vec3.new(0.0, 0.0, 0.0) if mag == 0.0
    Vec3.new(@x / mag, @y / mag, @z / mag)
  end

  def limit(max : Float64)
    mag = magnitude
    return self if mag <= max
    normalize * max
  end

  def distance_to(other : Vec3)
    (self - other).magnitude
  end

  def dot(other : Vec3)
    @x * other.x + @y * other.y + @z * other.z
  end

  def cross(other : Vec3)
    Vec3.new(
      @y * other.z - @z * other.y,
      @z * other.x - @x * other.z,
      @x * other.y - @y * other.x
    )
  end
end

# Individual 3D boid class
class Boid3D
  @@next_id = 0

  property position : Vec3
  property velocity : Vec3
  property acceleration : Vec3
  property max_speed : Float64
  property max_force : Float64
  property size : Float64
  property id : Int32

  def initialize(@position : Vec3, max_speed : Float64 = 3.0, max_force : Float64 = 0.1)
    @id = @@next_id
    @@next_id += 1
    # Random initial velocity with equal treatment for all axes
    angle_xy = rand * Math::PI * 2
    angle_z = (rand - 0.5) * Math::PI
    speed = 1.0 + rand * 2.0
    @velocity = Vec3.new(
      Math.cos(angle_xy) * Math.cos(angle_z) * speed,
      Math.sin(angle_xy) * Math.cos(angle_z) * speed,
      Math.sin(angle_z) * speed
    )
    @acceleration = Vec3.new(0.0, 0.0, 0.0)
    @max_speed = max_speed
    @max_force = max_force
    @size = 16.0 # Double the original size from 8.0 to 16.0
  end

  # Apply the three boid rules: separation, alignment, cohesion
  def flock(boids : Array(Boid3D), desired_separation : Float64, neighbor_distance : Float64, separation_weight : Float64, alignment_weight : Float64, cohesion_weight : Float64)
    sep = separate(boids, desired_separation)
    ali = align(boids, neighbor_distance)
    coh = cohesion(boids, neighbor_distance)

    # Weight the forces
    sep = sep * separation_weight
    ali = ali * alignment_weight
    coh = coh * cohesion_weight

    # Apply forces
    apply_force(sep)
    apply_force(ali)
    apply_force(coh)
  end

  # Separation: steer to avoid crowding local flockmates
  def separate(boids : Array(Boid3D), desired_separation : Float64)
    steer = Vec3.new(0.0, 0.0, 0.0)
    count = 0

    boids.each do |other|
      d = position.distance_to(other.position)
      if d > 0 && d < desired_separation
        diff = position - other.position
        diff = diff.normalize
        diff = diff / d # Weight by distance
        steer = steer + diff
        count += 1
      end
    end

    if count > 0
      steer = steer / count.to_f
      steer = steer.normalize
      steer = steer * max_speed
      steer = steer - velocity
      steer = steer.limit(max_force)
    end

    steer
  end

  # Alignment: steer towards the average heading of neighbors
  def align(boids : Array(Boid3D), neighbor_dist : Float64)
    sum = Vec3.new(0.0, 0.0, 0.0)
    count = 0

    boids.each do |other|
      d = position.distance_to(other.position)
      if d > 0 && d < neighbor_dist
        sum = sum + other.velocity
        count += 1
      end
    end

    if count > 0
      sum = sum / count.to_f
      sum = sum.normalize
      sum = sum * max_speed
      steer = sum - velocity
      steer = steer.limit(max_force)
      return steer
    end

    Vec3.new(0.0, 0.0, 0.0)
  end

  # Cohesion: steer to move toward the average position of neighbors
  def cohesion(boids : Array(Boid3D), neighbor_dist : Float64)
    sum = Vec3.new(0.0, 0.0, 0.0)
    count = 0

    boids.each do |other|
      d = position.distance_to(other.position)
      if d > 0 && d < neighbor_dist
        sum = sum + other.position
        count += 1
      end
    end

    if count > 0
      sum = sum / count.to_f
      return seek(sum)
    end

    Vec3.new(0.0, 0.0, 0.0)
  end

  # Seek a target position
  def seek(target : Vec3)
    desired = target - position
    desired = desired.normalize
    desired = desired * max_speed

    steer = desired - velocity
    steer = steer.limit(max_force)
    steer
  end

  # Apply a force to the boid
  def apply_force(force : Vec3)
    @acceleration = @acceleration + force
  end

  # Update boid position and velocity
  def update(width : Float64, height : Float64, depth : Float64)
    # Update velocity
    @velocity = @velocity + @acceleration
    @velocity = @velocity.limit(@max_speed)

    # Update position
    @position = @position + @velocity

    # Reset acceleration
    @acceleration = Vec3.new(0.0, 0.0, 0.0)

    # Wrap around edges
    @position.x = (@position.x + width) % width
    @position.y = (@position.y + height) % height
    @position.z = (@position.z + depth) % depth
  end

  # Project 3D position to 2D screen coordinates
  def project_to_2d(camera_distance : Float64, screen_width : Float64, screen_height : Float64)
    # Handle camera distance of 0 by using a small epsilon value
    effective_camera_distance = camera_distance == 0.0 ? 0.1 : camera_distance

    # Simple perspective projection with natural scaling
    # When camera_distance is very small, objects at z=0 are very large, objects far away are small
    scale = effective_camera_distance / (effective_camera_distance + @position.z)

    # Ensure scale doesn't become too extreme (clamp between reasonable values)
    scale = scale.clamp(0.01, 10.0)

    screen_x = (@position.x - screen_width / 2) * scale + screen_width / 2
    screen_y = (@position.y - screen_height / 2) * scale + screen_height / 2
    {x: screen_x, y: screen_y, scale: scale}
  end
end

class SpatialHashGrid3D
  alias CellKey = Tuple(Int32, Int32, Int32)

  property cell_size : Float64
  property grid : Hash(CellKey, Array(Boid3D))

  def initialize(@cell_size : Float64)
    @grid = Hash(CellKey, Array(Boid3D)).new
  end

  def clear
    @grid.clear
  end

  def add_boid(boid : Boid3D)
    key = hash_position(boid.position.x, boid.position.y, boid.position.z)
    (@grid[key] ||= [] of Boid3D) << boid
  end

  def get_neighbors(position : Vec3, radius : Float64) : Array(Boid3D)
    neighbors = [] of Boid3D
    cell_radius = (radius / @cell_size).ceil.to_i
    center_x = (position.x / @cell_size).floor.to_i
    center_y = (position.y / @cell_size).floor.to_i
    center_z = (position.z / @cell_size).floor.to_i
    (-cell_radius..cell_radius).each do |delta_x|
      (-cell_radius..cell_radius).each do |delta_y|
        (-cell_radius..cell_radius).each do |delta_z|
          key = {center_x + delta_x, center_y + delta_y, center_z + delta_z}
          if cell = @grid[key]?
            neighbors.concat(cell)
          end
        end
      end
    end
    neighbors
  end

  private def hash_position(x : Float64, y : Float64, z : Float64) : CellKey
    cx = (x / @cell_size).floor.to_i
    cy = (y / @cell_size).floor.to_i
    cz = (z / @cell_size).floor.to_i
    {cx, cy, cz}
  end
end

class BoidSimulation3D
  property boids : Array(Boid3D)
  property width : Float64
  property height : Float64
  property depth : Float64
  property? animation_running : Bool
  property camera_distance : Float64

  property grid : SpatialHashGrid3D

  # Simulation parameters
  property boid_count : Int32
  property separation_weight : Float64
  property alignment_weight : Float64
  property cohesion_weight : Float64
  property desired_separation : Float64
  property neighbor_distance : Float64
  property max_speed : Float64
  property max_force : Float64

  def initialize(@width : Float64 = 900.0, @height : Float64 = 600.0, @depth : Float64 = 800.0)
    @boids = [] of Boid3D
    @animation_running = false
    @camera_distance = 100.0

    @boid_count = DEFAULT_BOID_COUNT
    @separation_weight = 2.0
    @alignment_weight = 1.0
    @cohesion_weight = 1.0
    @desired_separation = 25.0
    @neighbor_distance = 50.0
    @max_speed = 3.0
    @max_force = 0.1

    @grid = SpatialHashGrid3D.new(@neighbor_distance)
    create_initial_boids
  end

  def create_initial_boids
    @boids.clear
    @boid_count.times do
      x = rand * @width
      y = rand * @height
      z = rand * @depth
      @boids << Boid3D.new(Vec3.new(x, y, z), @max_speed, @max_force)
    end
  end

  def reset_boids
    create_initial_boids
  end

  def add_boid(position : Vec3)
    @boids << Boid3D.new(position, @max_speed, @max_force)
  end

  def add_boid_at_screen_position(screen_x : Float64, screen_y : Float64)
    z = @depth / 2
    scale = @camera_distance / (@camera_distance + z)
    x = (screen_x - @width / 2) / scale + @width / 2
    y = (screen_y - @height / 2) / scale + @height / 2
    add_boid(Vec3.new(x, y, z))
  end

  def update_simulation
    @grid.cell_size = @neighbor_distance
    @grid.clear
    @boids.each do |boid|
      @grid.add_boid(boid)
    end
    @boids.each do |boid|
      neighbors = @grid.get_neighbors(boid.position, @neighbor_distance)
      boid.flock(neighbors, @desired_separation, @neighbor_distance, @separation_weight, @alignment_weight, @cohesion_weight)
      boid.update(@width, @height, @depth)
    end
  end

  def update_existing_boids_parameters
    # Update existing boids with new parameters
    @boids.each do |boid|
      boid.max_speed = @max_speed
      boid.max_force = @max_force
    end
  end

  def recreate_boids_if_count_changed
    # Recreate boids if count changed
    if @boids.size != @boid_count
      create_initial_boids
    end
  end

  def reset_to_defaults
    @boid_count = DEFAULT_BOID_COUNT
    @separation_weight = 2.0
    @alignment_weight = 1.0
    @cohesion_weight = 1.0
    @desired_separation = 25.0
    @neighbor_distance = 50.0
    @max_speed = 3.0
    @max_force = 0.1
    @camera_distance = 100.0 # Updated to match the moderate camera distance
  end

  # Get boids sorted by depth (for proper rendering order)
  def boids_sorted_by_depth
    @boids.sort_by { |boid| -boid.position.z }
  end

  # HSV to RGB conversion
  def hsv_to_rgb(h : Float64, s : Float64, v : Float64)
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

class BoidRenderer3D
  def initialize(@simulation : BoidSimulation3D)
  end

  def draw(params)
    ctx = params.context
    @simulation.width = params.area_width
    @simulation.height = params.area_height

    draw_background(ctx, params.area_width, params.area_height)
    @simulation.boids_sorted_by_depth.each do |boid|
      draw_boid(ctx, boid)
    end
    draw_depth_indicator(ctx)
  end

  private def draw_background(ctx, width : Float64, height : Float64)
    brush = UIng::Area::Draw::Brush.new(:solid, 0.0, 0.05, 0.15, 1.0)
    ctx.fill_path(brush) do |path|
      path.add_rectangle(0, 0, width, height)
    end
  end

  private def draw_boid(ctx, boid : Boid3D)
    projection = boid.project_to_2d(@simulation.camera_distance, @simulation.width, @simulation.height)
    return if outside_view?(projection[:x], projection[:y])

    depth_factor = (boid.position.z / @simulation.depth).clamp(0.0, 1.0)
    rgb = boid_color(boid, depth_factor)
    base_alpha = 0.3 + 0.5 * (1.0 - depth_factor)
    layer_alpha = base_alpha * 0.7
    size = boid.size * projection[:scale]

    draw_head(ctx, projection[:x], projection[:y], size, rgb, layer_alpha)
    draw_tail(ctx, boid, projection[:x], projection[:y], size, rgb, base_alpha)
  end

  private def outside_view?(x : Float64, y : Float64) : Bool
    x < -50 || x > @simulation.width + 50 ||
      y < -50 || y > @simulation.height + 50
  end

  private def boid_color(boid : Boid3D, depth_factor : Float64)
    base_hue = (boid.id * 0.1) % 1.0
    underwater_hue = 0.5
    underwater_influence = depth_factor * 0.7
    hue = base_hue * (1.0 - underwater_influence) + underwater_hue * underwater_influence
    saturation = 0.7 * (1.0 - depth_factor * 0.7)
    brightness = 0.5 + 0.5 * (1.0 - depth_factor)

    @simulation.hsv_to_rgb(hue, saturation, brightness)
  end

  private def draw_head(ctx, x : Float64, y : Float64, size : Float64, rgb, alpha : Float64)
    outer_brush = UIng::Area::Draw::Brush.new(:solid, rgb[:r], rgb[:g], rgb[:b], alpha)
    draw_circle(ctx, outer_brush, x, y, size / 2)

    inner_brush = UIng::Area::Draw::Brush.new(
      :solid,
      rgb[:r] * 0.8 + 0.2,
      rgb[:g] * 0.8 + 0.2,
      rgb[:b] * 0.8 + 0.2,
      alpha
    )
    draw_circle(ctx, inner_brush, x, y, size * 0.3)
  end

  private def draw_circle(ctx, brush, x : Float64, y : Float64, radius : Float64)
    ctx.fill_path(brush) do |path|
      path.new_figure_with_arc(x, y, radius, 0, Math::PI * 2, false)
    end
  end

  private def draw_tail(ctx, boid : Boid3D, x : Float64, y : Float64, size : Float64, rgb, base_alpha : Float64)
    return unless size > 2

    velocity = boid.velocity
    speed_2d = Math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
    speed_3d = velocity.magnitude
    return if speed_2d <= 0 || speed_3d <= 0

    tail_ratio = speed_2d / speed_3d
    tail_length = size * 3.0 * tail_ratio
    tail_width = size * 0.9 * tail_ratio
    return unless tail_length > size * 0.2

    tail_dir_x = -(velocity.x / speed_2d)
    tail_dir_y = -(velocity.y / speed_2d)
    perp_x = -tail_dir_y
    perp_y = tail_dir_x
    start_offset = size * 0.2
    start_x = x + tail_dir_x * start_offset
    start_y = y + tail_dir_y * start_offset
    tail_alpha = base_alpha * 0.6 * tail_ratio

    draw_tail_triangle(ctx, start_x, start_y, tail_dir_x, tail_dir_y, perp_x, perp_y, tail_length, tail_width, rgb, tail_alpha)
    draw_tail_spine(ctx, start_x, start_y, tail_dir_x, tail_dir_y, perp_x, perp_y, tail_length, tail_width, rgb, tail_alpha)
  end

  private def draw_tail_triangle(ctx, start_x, start_y, dir_x, dir_y, perp_x, perp_y, length, width, rgb, alpha)
    brush = UIng::Area::Draw::Brush.new(:solid, rgb[:r], rgb[:g], rgb[:b], alpha)
    fill_tail_triangle(ctx, brush, start_x, start_y, dir_x, dir_y, perp_x, perp_y, length, width)
  end

  private def draw_tail_spine(ctx, start_x, start_y, dir_x, dir_y, perp_x, perp_y, length, width, rgb, alpha)
    brush = UIng::Area::Draw::Brush.new(
      :solid,
      rgb[:r] * 0.7 + 0.3,
      rgb[:g] * 0.7 + 0.3,
      rgb[:b] * 0.7 + 0.3,
      alpha * 0.8
    )
    fill_tail_triangle(ctx, brush, start_x, start_y, dir_x, dir_y, perp_x, perp_y, length * 0.6, width * 0.6)
  end

  private def fill_tail_triangle(ctx, brush, start_x, start_y, dir_x, dir_y, perp_x, perp_y, length, width)
    tip_x = start_x + dir_x * length
    tip_y = start_y + dir_y * length
    left_x = start_x + perp_x * width / 2
    left_y = start_y + perp_y * width / 2
    right_x = start_x - perp_x * width / 2
    right_y = start_y - perp_y * width / 2

    ctx.fill_path(brush) do |path|
      path.new_figure(left_x, left_y)
      path.line_to(tip_x, tip_y)
      path.line_to(right_x, right_y)
      path.close_figure
    end
  end

  private def draw_depth_indicator(ctx)
    brush = UIng::Area::Draw::Brush.new(:solid, 0.5, 0.5, 0.5, 0.7)
    ctx.stroke_path(brush, thickness: 1.0) do |path|
      scale_x = @simulation.width - 30
      scale_top = 50.0
      scale_bottom = @simulation.height - 50
      path.new_figure(scale_x, scale_top)
      path.line_to(scale_x, scale_bottom)

      (0..4).each do |index|
        tick_y = scale_top + (scale_bottom - scale_top) * index / 4
        path.new_figure(scale_x - 5, tick_y)
        path.line_to(scale_x + 5, tick_y)
      end
    end
  end
end

UIng.init

# Global 3D simulation instance
SIMULATION3D   = BoidSimulation3D.new
RENDERER3D     = BoidRenderer3D.new(SIMULATION3D)
STATUS_LABEL3D = UIng::Label.new("Running")

record BoidPreferenceControls,
  boid_count : UIng::Spinbox,
  separation_weight : UIng::Entry,
  alignment_weight : UIng::Entry,
  cohesion_weight : UIng::Entry,
  desired_separation : UIng::Entry,
  neighbor_distance : UIng::Entry,
  max_speed : UIng::Entry,
  max_force : UIng::Entry,
  camera_distance : UIng::Entry

def float_entry_3d(value : Float64) : UIng::Entry
  entry = UIng::Entry.new
  entry.text = value.to_s
  entry
end

def float_entry_value_3d(entry : UIng::Entry, fallback : Float64) : Float64
  (entry.text || "").to_f? || fallback
end

def new_preference_controls_3d : BoidPreferenceControls
  BoidPreferenceControls.new(
    UIng::Spinbox.new(10, 1000, value: SIMULATION3D.boid_count),
    float_entry_3d(SIMULATION3D.separation_weight),
    float_entry_3d(SIMULATION3D.alignment_weight),
    float_entry_3d(SIMULATION3D.cohesion_weight),
    float_entry_3d(SIMULATION3D.desired_separation),
    float_entry_3d(SIMULATION3D.neighbor_distance),
    float_entry_3d(SIMULATION3D.max_speed),
    float_entry_3d(SIMULATION3D.max_force),
    float_entry_3d(SIMULATION3D.camera_distance)
  )
end

def apply_preferences_3d(controls : BoidPreferenceControls)
  SIMULATION3D.boid_count = controls.boid_count.value
  SIMULATION3D.separation_weight = float_entry_value_3d(controls.separation_weight, SIMULATION3D.separation_weight)
  SIMULATION3D.alignment_weight = float_entry_value_3d(controls.alignment_weight, SIMULATION3D.alignment_weight)
  SIMULATION3D.cohesion_weight = float_entry_value_3d(controls.cohesion_weight, SIMULATION3D.cohesion_weight)
  SIMULATION3D.desired_separation = float_entry_value_3d(controls.desired_separation, SIMULATION3D.desired_separation)
  SIMULATION3D.neighbor_distance = float_entry_value_3d(controls.neighbor_distance, SIMULATION3D.neighbor_distance)
  SIMULATION3D.max_speed = float_entry_value_3d(controls.max_speed, SIMULATION3D.max_speed)
  SIMULATION3D.max_force = float_entry_value_3d(controls.max_force, SIMULATION3D.max_force)
  SIMULATION3D.camera_distance = float_entry_value_3d(controls.camera_distance, SIMULATION3D.camera_distance)

  SIMULATION3D.update_existing_boids_parameters
  SIMULATION3D.recreate_boids_if_count_changed
  STATUS_LABEL3D.text = "Applied #{SIMULATION3D.boid_count} boids"
  AREA3D.queue_redraw_all
end

def sync_preferences_controls_3d(controls : BoidPreferenceControls)
  controls.boid_count.value = SIMULATION3D.boid_count
  controls.separation_weight.text = SIMULATION3D.separation_weight.to_s
  controls.alignment_weight.text = SIMULATION3D.alignment_weight.to_s
  controls.cohesion_weight.text = SIMULATION3D.cohesion_weight.to_s
  controls.desired_separation.text = SIMULATION3D.desired_separation.to_s
  controls.neighbor_distance.text = SIMULATION3D.neighbor_distance.to_s
  controls.max_speed.text = SIMULATION3D.max_speed.to_s
  controls.max_force.text = SIMULATION3D.max_force.to_s
  controls.camera_distance.text = SIMULATION3D.camera_distance.to_s
end

# Create preferences window for 3D
def create_preferences_window_3d
  UIng::Window.new("Preferences", 400, 600, margined: true) do
    on_closing do
      STATUS_LABEL3D.text = "Preferences closed"
      true # Allow closing
    end

    controls = new_preference_controls_3d

    set_child(
      UIng::Box.new(:vertical, padded: true) do
        append(UIng::Label.new("3D Boid Simulation Parameters"), stretchy: false)
        append(
          UIng::Form.new(padded: true) do
            append("Boid Count:", controls.boid_count)
            append("Separation Weight:", controls.separation_weight)
            append("Alignment Weight:", controls.alignment_weight)
            append("Cohesion Weight:", controls.cohesion_weight)
            append("Separation Distance:", controls.desired_separation)
            append("Neighbor Distance:", controls.neighbor_distance)
            append("Max Speed:", controls.max_speed)
            append("Max Force:", controls.max_force)
            append("Camera Distance:", controls.camera_distance)
          end
        )
        append(
          UIng::Box.new(:horizontal, padded: true) do
            append(
              UIng::Button.new("Apply") do
                on_clicked do
                  apply_preferences_3d(controls)
                end
              end,
              stretchy: true
            )
            append(
              UIng::Button.new("Reset to Defaults") do
                on_clicked do
                  SIMULATION3D.reset_to_defaults
                  sync_preferences_controls_3d(controls)
                  SIMULATION3D.create_initial_boids
                  STATUS_LABEL3D.text = "Reset to #{SIMULATION3D.boid_count} boids"
                  AREA3D.queue_redraw_all
                end
              end,
              stretchy: true
            )
          end,
          stretchy: false
        )
      end
    )
    show

    # Center the window
    x = MAIN_WINDOW3D.position[0] + MAIN_WINDOW3D.content_size[0] / 2 - content_size[0] / 2
    y = MAIN_WINDOW3D.position[1] + MAIN_WINDOW3D.content_size[1] / 2 - content_size[1] / 2
    set_position(x.to_i, y.to_i)
  end
end

def setup_menus_3d
  UIng::Menu.new("File") do
    append_preferences_item.on_clicked do
      create_preferences_window_3d
    end
    append_separator
    append_quit_item
  end

  UIng.on_should_quit do
    SIMULATION3D.animation_running = false
    MAIN_WINDOW3D.destroy
    true
  end

  UIng::Menu.new("Help") do
    append_about_item.on_clicked do |window|
      window.msg_box("About", "Boid 3D Simulation\nA 3D flocking behavior demonstration with perspective projection\n\nPress [Space] to reset")
    end
  end
end

# Create UI components
HANDLER3D = UIng::Area::Handler.new
AREA3D    = UIng::Area.new(HANDLER3D)

# Setup handlers
def setup_handlers_3d
  HANDLER3D.draw do |_area, params|
    RENDERER3D.draw(params)
  end

  HANDLER3D.key_event do |area, event|
    if event.up == 0 # Key down
      case event.key
      when ' '.ord # Space key - reset
        SIMULATION3D.reset_boids
        STATUS_LABEL3D.text = "Reset #{SIMULATION3D.boids.size} boids"
        area.queue_redraw_all
      end
    end
    true
  end
end

def create_main_window_3d : UIng::Window
  vbox = UIng::Box.new(:vertical, padded: true)
  vbox.append(AREA3D, true)
  vbox.append(STATUS_LABEL3D, false)

  UIng::Window.new("Boid 3D Simulation", SIMULATION3D.width.to_i, (SIMULATION3D.height + 50).to_i, menubar: true) do
    on_closing do
      SIMULATION3D.animation_running = false
      UIng.quit
      true
    end
    set_child(vbox)
    show
  end
end

def start_animation_3d
  SIMULATION3D.animation_running = true
  UIng.timer(16) do
    if SIMULATION3D.animation_running?
      SIMULATION3D.update_simulation
      AREA3D.queue_redraw_all
      1 # Continue timer
    else
      0 # Stop timer
    end
  end
end

setup_menus_3d
setup_handlers_3d
MAIN_WINDOW3D = create_main_window_3d
start_animation_3d

UIng.main
UIng.uninit
