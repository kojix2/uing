require "../../src/uing"

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

  def *(scalar : Float64)
    Vec3.new(@x * scalar, @y * scalar, @z * scalar)
  end

  def /(scalar : Float64)
    Vec3.new(@x / scalar, @y / scalar, @z / scalar)
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
  property cell_size : Float64
  property grid : Hash(String, Array(Boid3D))

  def initialize(@cell_size : Float64)
    @grid = Hash(String, Array(Boid3D)).new
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
    (-cell_radius..cell_radius).each do |dx|
      (-cell_radius..cell_radius).each do |dy|
        (-cell_radius..cell_radius).each do |dz|
          key = hash_position(
            (center_x + dx) * @cell_size,
            (center_y + dy) * @cell_size,
            (center_z + dz) * @cell_size
          )
          if @grid.has_key?(key)
            neighbors.concat(@grid[key])
          end
        end
      end
    end
    neighbors
  end

  private def hash_position(x : Float64, y : Float64, z : Float64) : String
    cx = (x / @cell_size).floor.to_i
    cy = (y / @cell_size).floor.to_i
    cz = (z / @cell_size).floor.to_i
    "#{cx},#{cy},#{cz}"
  end
end

class BoidSimulation3D
  property boids : Array(Boid3D)
  property width : Float64
  property height : Float64
  property depth : Float64
  property animation_running : Bool
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

    @boid_count = 400
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
    @boid_count = 200 # 4 times the original default (50 -> 200)
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

UIng.init

# Global 3D simulation instance
SIMULATION3D = BoidSimulation3D.new

# Create preferences window for 3D
def create_preferences_window_3d
  UIng::Window.new("Preferences", 400, 600, margined: true) do
    on_closing do
      puts "Preferences window closed"
      true # Allow closing
    end

    # Create form controls
    boid_count_spinbox = UIng::Spinbox.new(10, 200, value: SIMULATION3D.boid_count)
    separation_weight_entry = UIng::Entry.new
    separation_weight_entry.text = SIMULATION3D.separation_weight.to_s
    alignment_weight_entry = UIng::Entry.new
    alignment_weight_entry.text = SIMULATION3D.alignment_weight.to_s
    cohesion_weight_entry = UIng::Entry.new
    cohesion_weight_entry.text = SIMULATION3D.cohesion_weight.to_s
    desired_separation_entry = UIng::Entry.new
    desired_separation_entry.text = SIMULATION3D.desired_separation.to_s
    neighbor_distance_entry = UIng::Entry.new
    neighbor_distance_entry.text = SIMULATION3D.neighbor_distance.to_s
    max_speed_entry = UIng::Entry.new
    max_speed_entry.text = SIMULATION3D.max_speed.to_s
    max_force_entry = UIng::Entry.new
    max_force_entry.text = SIMULATION3D.max_force.to_s
    camera_distance_entry = UIng::Entry.new
    camera_distance_entry.text = SIMULATION3D.camera_distance.to_s

    set_child(
      UIng::Box.new(:vertical, padded: true) do
        append(UIng::Label.new("3D Boid Simulation Parameters"), stretchy: false)
        append(
          UIng::Form.new(padded: true) do
            append("Boid Count:", boid_count_spinbox)
            append("Separation Weight:", separation_weight_entry)
            append("Alignment Weight:", alignment_weight_entry)
            append("Cohesion Weight:", cohesion_weight_entry)
            append("Separation Distance:", desired_separation_entry)
            append("Neighbor Distance:", neighbor_distance_entry)
            append("Max Speed:", max_speed_entry)
            append("Max Force:", max_force_entry)
            append("Camera Distance:", camera_distance_entry)
          end
        )
        append(
          UIng::Box.new(:horizontal, padded: true) do
            append(
              UIng::Button.new("Apply") do
                on_clicked do
                  # Update parameters
                  SIMULATION3D.boid_count = boid_count_spinbox.value
                  SIMULATION3D.separation_weight = (separation_weight_entry.text || "").to_f? || SIMULATION3D.separation_weight
                  SIMULATION3D.alignment_weight = (alignment_weight_entry.text || "").to_f? || SIMULATION3D.alignment_weight
                  SIMULATION3D.cohesion_weight = (cohesion_weight_entry.text || "").to_f? || SIMULATION3D.cohesion_weight
                  SIMULATION3D.desired_separation = (desired_separation_entry.text || "").to_f? || SIMULATION3D.desired_separation
                  SIMULATION3D.neighbor_distance = (neighbor_distance_entry.text || "").to_f? || SIMULATION3D.neighbor_distance
                  SIMULATION3D.max_speed = (max_speed_entry.text || "").to_f? || SIMULATION3D.max_speed
                  SIMULATION3D.max_force = (max_force_entry.text || "").to_f? || SIMULATION3D.max_force
                  SIMULATION3D.camera_distance = (camera_distance_entry.text || "").to_f? || SIMULATION3D.camera_distance

                  # Update existing boids and recreate if needed
                  SIMULATION3D.update_existing_boids_parameters
                  SIMULATION3D.recreate_boids_if_count_changed

                  AREA3D.queue_redraw_all
                end
              end,
              stretchy: true
            )
            append(
              UIng::Button.new("Reset to Defaults") do
                on_clicked do
                  SIMULATION3D.reset_to_defaults

                  # Update form controls
                  boid_count_spinbox.value = SIMULATION3D.boid_count
                  separation_weight_entry.text = SIMULATION3D.separation_weight.to_s
                  alignment_weight_entry.text = SIMULATION3D.alignment_weight.to_s
                  cohesion_weight_entry.text = SIMULATION3D.cohesion_weight.to_s
                  desired_separation_entry.text = SIMULATION3D.desired_separation.to_s
                  neighbor_distance_entry.text = SIMULATION3D.neighbor_distance.to_s
                  max_speed_entry.text = SIMULATION3D.max_speed.to_s
                  max_force_entry.text = SIMULATION3D.max_force.to_s
                  camera_distance_entry.text = SIMULATION3D.camera_distance.to_s

                  SIMULATION3D.create_initial_boids
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

# File menu
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

# Help menu
UIng::Menu.new("Help") do
  append_about_item.on_clicked do |w|
    w.msg_box("About", "Boid 3D Simulation\nA 3D flocking behavior demonstration with perspective projection\n\nPress [Space] to reset")
  end
end

# Create UI components
HANDLER3D = UIng::Area::Handler.new
AREA3D    = UIng::Area.new(HANDLER3D)

# Setup handlers
HANDLER3D.draw do |area, params|
  ctx = params.context

  # Draw background with gradient to suggest underwater depth
  bg_brush = UIng::Area::Draw::Brush.new(:solid, 0.0, 0.05, 0.15, 1.0) # Deep blue-green underwater color
  ctx.fill_path(bg_brush) do |path|
    path.add_rectangle(0, 0, SIMULATION3D.width, SIMULATION3D.height)
  end

  # Draw boids sorted by depth (back to front)
  SIMULATION3D.boids_sorted_by_depth.each_with_index do |boid, i|
    # Project 3D position to 2D screen coordinates
    projection = boid.project_to_2d(SIMULATION3D.camera_distance, SIMULATION3D.width, SIMULATION3D.height)

    # Skip if projected outside screen bounds
    next if projection[:x] < -50 || projection[:x] > SIMULATION3D.width + 50 ||
            projection[:y] < -50 || projection[:y] > SIMULATION3D.height + 50

    # Color based on depth and boid ID for consistent variety
    depth_factor = (boid.position.z / SIMULATION3D.depth).clamp(0.0, 1.0)
    base_hue = (boid.id * 0.1) % 1.0

    # Add blue-green tint for distant objects (underwater perspective)
    underwater_hue = 0.5                      # Blue-green hue value (around 180 degrees - cyan/teal)
    underwater_influence = depth_factor * 0.7 # Strong underwater color influence
    hue = base_hue * (1.0 - underwater_influence) + underwater_hue * underwater_influence

    # Reduce saturation for distant objects (more gray/blue)
    saturation = 0.7 * (1.0 - depth_factor * 0.7) # Increased from 0.5 to 0.7 for more desaturation
    brightness = 0.5 + 0.5 * (1.0 - depth_factor) # Brighter when closer
    rgb = SIMULATION3D.hsv_to_rgb(hue, saturation, brightness)

    # Alpha based on depth (more transparent when far) - adjusted for double layer
    base_alpha = 0.3 + 0.5 * (1.0 - depth_factor)
    # Each layer should be more transparent so that when combined they equal the original alpha
    layer_alpha = base_alpha * 0.7 # Each layer is 70% of target, so 0.7 + 0.7*0.3 ≈ original

    # Size based on perspective with natural scaling
    base_scale = projection[:scale]
    # Use natural perspective scaling - objects get smaller with distance
    size = boid.size * base_scale

    # Draw outer head (body) as a proper circle
    outer_brush = UIng::Area::Draw::Brush.new(:solid, rgb[:r], rgb[:g], rgb[:b], layer_alpha)
    ctx.fill_path(outer_brush) do |path|
      radius = size / 2
      # Create a circle using arc
      path.new_figure_with_arc(
        projection[:x], projection[:y],
        radius,
        0, Math::PI * 2,
        false
      )
    end

    # Draw inner head (brain) as a smaller circle
    inner_head_scale = 0.6 # Inner head is 60% of outer size
    inner_size = size * inner_head_scale
    inner_radius = inner_size / 2

    # Inner head (brain) with whitish color
    brain_r = rgb[:r] * 0.8 + 0.2 # Add white tint
    brain_g = rgb[:g] * 0.8 + 0.2
    brain_b = rgb[:b] * 0.8 + 0.2
    inner_brush = UIng::Area::Draw::Brush.new(:solid, brain_r, brain_g, brain_b, layer_alpha)
    ctx.fill_path(inner_brush) do |path|
      # Create a circle using arc
      path.new_figure_with_arc(
        projection[:x], projection[:y],
        inner_radius,
        0, Math::PI * 2,
        false
      )
    end

    # Draw a triangular tail (like a tadpole) opposite to movement direction
    # Tail length varies based on 3D movement direction to show depth movement
    if size > 2
      vel_2d = boid.velocity
      vel_3d = boid.velocity # Get full 3D velocity
      vel_magnitude_2d = Math.sqrt(vel_2d.x * vel_2d.x + vel_2d.y * vel_2d.y)
      vel_magnitude_3d = Math.sqrt(vel_3d.x * vel_3d.x + vel_3d.y * vel_3d.y + vel_3d.z * vel_3d.z)

      if vel_magnitude_2d > 0 && vel_magnitude_3d > 0
        # Calculate tail length based on 2D vs 3D velocity ratio
        # When moving purely in X/Y plane, ratio = 1.0 (full tail length)
        # When moving purely in Z direction, ratio approaches 0 (short tail)
        tail_length_ratio = vel_magnitude_2d / vel_magnitude_3d
        tail_length = size * 3.0 * tail_length_ratio # Doubled from 1.5 to 3.0
        tail_width = size * 0.9 * tail_length_ratio  # Increased from 0.6 to 0.9 (closer to original 1.2)

        # Only draw tail if it's visible (not too short)
        if tail_length > size * 0.2
          # Calculate tail direction (opposite to 2D velocity)
          tail_dir_x = -(vel_2d.x / vel_magnitude_2d)
          tail_dir_y = -(vel_2d.y / vel_magnitude_2d)

          # Calculate perpendicular direction for tail width
          perp_x = -tail_dir_y
          perp_y = tail_dir_x

          # Start tail closer to head center (more like original)
          head_radius = size / 2
          tail_start_offset = head_radius * 0.4 # Reduced from 0.7 to 0.4 (closer to center)
          tail_start_x = projection[:x] + tail_dir_x * tail_start_offset
          tail_start_y = projection[:y] + tail_dir_y * tail_start_offset

          # Calculate tail tip position
          tail_tip_x = tail_start_x + tail_dir_x * tail_length
          tail_tip_y = tail_start_y + tail_dir_y * tail_length

          # Calculate tail base corners (narrower attachment)
          base_left_x = tail_start_x + perp_x * tail_width / 2
          base_left_y = tail_start_y + perp_y * tail_width / 2
          base_right_x = tail_start_x - perp_x * tail_width / 2
          base_right_y = tail_start_y - perp_y * tail_width / 2

          # Draw triangular tail with alpha based on tail length ratio
          tail_alpha = base_alpha * 0.6 * tail_length_ratio
          tail_brush = UIng::Area::Draw::Brush.new(:solid, rgb[:r], rgb[:g], rgb[:b], tail_alpha)
          ctx.fill_path(tail_brush) do |path|
            path.new_figure(base_left_x, base_left_y)
            path.line_to(tail_tip_x, tail_tip_y)
            path.line_to(base_right_x, base_right_y)
            path.close_figure
          end

          # Draw smaller inner triangle to represent spine/backbone
          inner_scale = 0.6 # Make inner triangle 60% of outer size
          inner_tail_width = tail_width * inner_scale
          inner_tail_length = tail_length * inner_scale

          # Calculate inner triangle positions (also starting from tail start position)
          inner_tip_x = tail_start_x + tail_dir_x * inner_tail_length
          inner_tip_y = tail_start_y + tail_dir_y * inner_tail_length
          inner_left_x = tail_start_x + perp_x * inner_tail_width / 2
          inner_left_y = tail_start_y + perp_y * inner_tail_width / 2
          inner_right_x = tail_start_x - perp_x * inner_tail_width / 2
          inner_right_y = tail_start_y - perp_y * inner_tail_width / 2

          # Draw inner triangle (spine/backbone) with whitish color
          inner_alpha = tail_alpha * 0.8
          spine_r = rgb[:r] * 0.7 + 0.3 # Add more white tint for spine
          spine_g = rgb[:g] * 0.7 + 0.3
          spine_b = rgb[:b] * 0.7 + 0.3
          inner_brush = UIng::Area::Draw::Brush.new(:solid, spine_r, spine_g, spine_b, inner_alpha)
          ctx.fill_path(inner_brush) do |path|
            path.new_figure(inner_left_x, inner_left_y)
            path.line_to(inner_tip_x, inner_tip_y)
            path.line_to(inner_right_x, inner_right_y)
            path.close_figure
          end
        end
      end
    end
  end

  # Draw depth indicator
  depth_brush = UIng::Area::Draw::Brush.new(:solid, 0.5, 0.5, 0.5, 0.7)
  ctx.stroke_path(depth_brush, thickness: 1.0) do |path|
    # Draw a simple depth scale on the right side
    scale_x = SIMULATION3D.width - 30
    scale_top = 50.0
    scale_bottom = SIMULATION3D.height - 50
    path.new_figure(scale_x, scale_top)
    path.line_to(scale_x, scale_bottom)

    # Add tick marks
    (0..4).each do |i|
      tick_y = scale_top + (scale_bottom - scale_top) * i / 4
      path.new_figure(scale_x - 5, tick_y)
      path.line_to(scale_x + 5, tick_y)
    end
  end
end

HANDLER3D.key_event do |area, event|
  if event.up == 0 # Key down
    case event.key
    when ' '.ord # Space key - reset
      SIMULATION3D.reset_boids
      area.queue_redraw_all
    end
  end
  true
end

# Create main window
vbox3d = UIng::Box.new(:vertical, padded: true)
vbox3d.append(AREA3D, true)

MAIN_WINDOW3D = UIng::Window.new("Boid 3D Simulation", SIMULATION3D.width.to_i, (SIMULATION3D.height + 50).to_i, menubar: true) do
  on_closing do
    SIMULATION3D.animation_running = false
    UIng.quit
    true
  end
  show
end

MAIN_WINDOW3D.child = vbox3d

# Start animation
SIMULATION3D.animation_running = true
UIng.timer(16) do
  if SIMULATION3D.animation_running
    SIMULATION3D.update_simulation
    AREA3D.queue_redraw_all
    1 # Continue timer
  else
    0 # Stop timer
  end
end

UIng.main
UIng.uninit
