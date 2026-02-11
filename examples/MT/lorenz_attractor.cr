require "../src/uing"
require "math"

# Lorenz attractor parameters
SIGMA      = 10.0
RHO        = 28.0
BETA       = 8.0/3.0
DT         =  0.01
MAX_POINTS = 10000

struct Point3D
  property x : Float64
  property y : Float64
  property z : Float64

  def initialize(@x : Float64, @y : Float64, @z : Float64)
  end
end

struct Point2D
  property x : Float64
  property y : Float64

  def initialize(@x : Float64, @y : Float64)
  end
end

class LorenzAttractor
  @points = [] of Point3D
  @projected_points = [] of Point2D
  @points_mutex = Mutex.new
  @animation_running = false
  @area : UIng::Area?
  @window : UIng::Window?
  @button : UIng::Button?
  @sigma_entry : UIng::Entry?
  @rho_entry : UIng::Entry?
  @beta_entry : UIng::Entry?
  @dt_entry : UIng::Entry?
  @max_points_entry : UIng::Entry?
  @workers_spinbox : UIng::Spinbox?
  @color_button : UIng::ColorButton?
  @progress_bar : UIng::ProgressBar?

  @gui_context : Fiber::ExecutionContext::Isolated?
  @worker_context : Fiber::ExecutionContext::MultiThreaded?
  @points_channel = Channel(Array(Point3D)).new(100)
  @progress_channel = Channel(Int32).new(100)

  # Current parameters
  @sigma = SIGMA
  @rho = RHO
  @beta = BETA
  @dt = DT
  @max_points = MAX_POINTS
  @num_workers = 4

  def initialize
    @worker_context = Fiber::ExecutionContext::MultiThreaded.new("workers", 4)
  end

  private def lorenz_step(point : Point3D) : Point3D
    dx = @sigma * (point.y - point.x)
    dy = point.x * (@rho - point.z) - point.y
    dz = point.x * point.y - @beta * point.z

    Point3D.new(
      point.x + dx * @dt,
      point.y + dy * @dt,
      point.z + dz * @dt
    )
  end

  private def project_3d_to_2d(point : Point3D, width : Float64, height : Float64) : Point2D
    Point2D.new(
      width / 2 + point.x * 8,
      height / 2 + point.y * 8
    )
  end

  private def update_parameters
    @sigma = @sigma_entry.try(&.text.try(&.to_f?)) || SIGMA
    @rho = @rho_entry.try(&.text.try(&.to_f?)) || RHO
    @beta = @beta_entry.try(&.text.try(&.to_f?)) || BETA
    @dt = @dt_entry.try(&.text.try(&.to_f?)) || DT
    @max_points = @max_points_entry.try(&.text.try(&.to_i?)) || MAX_POINTS
    @num_workers = @workers_spinbox.try(&.value) || 4
  end

  private def start_calculation_worker
    return if @animation_running

    update_parameters
    @animation_running = true

    if worker_context = @worker_context
      # Start multiple workers for parallel computation
      @num_workers.times do |worker_id|
        worker_context.spawn do
          # Each worker uses slightly different initial conditions
          offset = worker_id * 0.1
          current = Point3D.new(1.0 + offset, 1.0 + offset, 1.0 + offset)
          local_points = [] of Point3D
          points_per_worker = @max_points // @num_workers
          start_point = worker_id * points_per_worker
          end_point = if worker_id == @num_workers - 1
                        @max_points
                      else
                        (worker_id + 1) * points_per_worker
                      end

          (start_point...end_point).each do |i|
            break unless @animation_running

            # Simple Lorenz calculation
            current = lorenz_step(current)

            local_points << current

            if i % 10 == 0
              i, result = Channel.non_blocking_select(@points_channel.send_select_action(local_points.dup))
              case result
              when Channel::NotReady
                # Channel not ready, skip
              else
                # Send successful
              end
            end

            # Send progress update every 100 points
            if i % 100 == 0
              progress = ((i.to_f / @max_points) * 100).to_i
              i, result = Channel.non_blocking_select(@progress_channel.send_select_action(progress))
              case result
              when Channel::NotReady
                # Skip progress update
              else
                # Send successful
              end
            end

            # Yield control at appropriate intervals
            if i % 10 == 0
              Fiber.yield
            end
          end

          # Send completion progress
          i, result = Channel.non_blocking_select(@progress_channel.send_select_action(100))

          # Send completion signal
          i, result = Channel.non_blocking_select(@progress_channel.send_select_action(-1))

          i, result = Channel.non_blocking_select(@points_channel.send_select_action(local_points.dup))
        end
      end
    end
  end

  private def stop_calculation
    @animation_running = false
  end

  private def create_draw_handler
    UIng::Area::Handler.new.tap do |handler|
      handler.draw do |area, area_draw_params|
        ctx = area_draw_params.context

        i, result = Channel.non_blocking_select(@points_channel.receive_select_action)
        if i == 0 && !result.is_a?(Channel::NotReady)
          @points_mutex.synchronize do
            @points = result.as(Array(Point3D))
          end
        end

        @points_mutex.synchronize do
          next if @points.size < 2

          @projected_points.clear
          @points.each do |point|
            @projected_points << project_3d_to_2d(point, area_draw_params.area_width, area_draw_params.area_height)
          end

          UIng::DrawPath.open(UIng::DrawFillMode::Winding) do |path|
            if @projected_points.size > 0
              path.new_figure(@projected_points[0].x, @projected_points[0].y)

              @projected_points[1..-1].each do |point|
                path.line_to(point.x, point.y)
              end
              path.end_

              brush = UIng::DrawBrush.new
              brush.type = UIng::DrawBrushType::Solid

              # Get color from color button
              if color_button = @color_button
                r, g, b, a = color_button.color
                brush.r = r
                brush.g = g
                brush.b = b
                brush.a = a
              else
                brush.r = 0.0
                brush.g = 0.8
                brush.b = 1.0
                brush.a = 0.8
              end

              stroke_params = UIng::DrawStrokeParams.new
              stroke_params.cap = UIng::DrawLineCap::Round
              stroke_params.join = UIng::DrawLineJoin::Round
              stroke_params.thickness = 1.0
              stroke_params.miter_limit = 10.0

              ctx.stroke(path, brush, stroke_params)
            end
          end
        end
      end

      handler.mouse_event { |area, event| }
      handler.mouse_crossed { |area, left| }
      handler.drag_broken { |area| }
      handler.key_event { |area, event| false }
    end
  end

  private def on_start_stop_clicked
    if @animation_running
      stop_calculation
      UIng.queue_main do
        @button.try(&.text = "Start")
      end
    else
      start_calculation_worker
      UIng.queue_main do
        @button.try(&.text = "Stop")
      end
    end
  end

  def run_gui
    @gui_context = Fiber::ExecutionContext::Isolated.new("GUI") do
      UIng.init

      @window = UIng::Window.new("Lorenz Attractor", 600, 700)
      window = @window.not_nil!
      window.margined = true

      vbox = UIng::Box.new(:vertical)
      vbox.padded = true

      # Top row: Parameters and Controls
      top_hbox = UIng::Box.new(:horizontal)
      top_hbox.padded = true

      # Parameter controls
      params_group = UIng::Group.new("Parameters")
      params_group.margined = true

      params_form = UIng::Form.new
      params_form.padded = true

      @sigma_entry = UIng::Entry.new
      @sigma_entry.try(&.text = SIGMA.to_s)
      params_form.append("Sigma:", @sigma_entry.not_nil!, false)

      @rho_entry = UIng::Entry.new
      @rho_entry.try(&.text = RHO.to_s)
      params_form.append("Rho:", @rho_entry.not_nil!, false)

      @beta_entry = UIng::Entry.new
      @beta_entry.try(&.text = BETA.to_s)
      params_form.append("Beta:", @beta_entry.not_nil!, false)

      @dt_entry = UIng::Entry.new
      @dt_entry.try(&.text = DT.to_s)
      params_form.append("dt:", @dt_entry.not_nil!, false)

      @max_points_entry = UIng::Entry.new
      @max_points_entry.try(&.text = MAX_POINTS.to_s)
      params_form.append("Max Points:", @max_points_entry.not_nil!, false)

      params_group.child = params_form
      top_hbox.append(params_group, true)

      # Controls group
      controls_group = UIng::Group.new("Controls")
      controls_group.margined = true

      controls_vbox = UIng::Box.new(:vertical)
      controls_vbox.padded = true

      # Workers spinbox
      @workers_spinbox = UIng::Spinbox.new(1, 16)
      @workers_spinbox.try(&.value = 4)
      controls_vbox.append(UIng::Label.new("Workers:"), false)
      controls_vbox.append(@workers_spinbox.not_nil!, false)

      # Color selection
      @color_button = UIng::ColorButton.new
      @color_button.try(&.set_color(0.0, 0.8, 1.0, 0.8))
      controls_vbox.append(UIng::Label.new("Color:"), false)
      controls_vbox.append(@color_button.not_nil!, false)

      # Progress bar
      @progress_bar = UIng::ProgressBar.new
      controls_vbox.append(UIng::Label.new("Progress:"), false)
      controls_vbox.append(@progress_bar.not_nil!, false)

      # Start/Stop button
      @button = UIng::Button.new("Start")
      button = @button.not_nil!
      button.on_clicked do
        on_start_stop_clicked
      end
      controls_vbox.append(button, false)

      controls_group.child = controls_vbox
      top_hbox.append(controls_group, false)

      vbox.append(top_hbox, false)

      # Drawing area
      handler = create_draw_handler
      @area = UIng::Area.new(handler)
      area = @area.not_nil!
      vbox.append(area, true)

      window.child = vbox

      window.on_closing do
        stop_calculation
        UIng.quit
        true
      end

      UIng.timer(16) do
        if @animation_running
          @area.try(&.queue_redraw_all)
        end

        # Update progress bar
        i, result = Channel.non_blocking_select(@progress_channel.receive_select_action)
        if i == 0
          progress = result.as(Int32)
          if progress == -1
            # Calculation completed
            @animation_running = false
            @button.try(&.text = "Completed")
            @progress_bar.try(&.value = 100)
          else
            @progress_bar.try(&.value = progress)
          end
        end

        1
      end

      window.show
      UIng.main
      UIng.uninit
    end

    @gui_context.try(&.wait)
  end

  def start
    run_gui
  end
end

def main
  attractor = LorenzAttractor.new
  attractor.start
end

main
