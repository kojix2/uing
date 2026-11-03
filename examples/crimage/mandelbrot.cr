require "../../src/uing"
require "math"

# Run with:
#   crystal run examples/crimage/mandelbrot.cr
# Drag with the left button to pan; scroll up/down to zoom at the pointer.

WIDTH           = 1200
HEIGHT          =  900
TILE_SIZE       =   32
DEFAULT_ITERS   =  500
DEFAULT_WORKERS =    4
LEFT_BUTTON     =    1
DEFAULT_CENTER_X =  -0.75
DEFAULT_CENTER_Y =   0.0
DEFAULT_SCALE    =   2.4

record RenderConfig,
  job_id : Int32,
  width : Int32,
  height : Int32,
  max_iterations : Int32,
  center_x : Float64,
  center_y : Float64,
  scale : Float64,
  palette : Int32

record Tile,
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32

record TileResult,
  job_id : Int32,
  tile : Tile,
  pixels : Bytes

record WorkerDone,
  job_id : Int32

alias RenderMessage = TileResult | WorkerDone

class MandelbrotRenderer
  @handler : UIng::Area::Handler
  @area : UIng::Area
  @window : UIng::Window
  @workers_spinbox : UIng::Spinbox
  @iterations_spinbox : UIng::Spinbox
  @palette_combobox : UIng::Combobox
  @progress_bar : UIng::ProgressBar
  @render_stop_button : UIng::Button
  @reset_button : UIng::Button
  @status_label : UIng::Label
  @image_buffer : UIng::ImageBuffer

  @background = Bytes.new(WIDTH * HEIGHT * 4, 0_u8)
  @messages = Channel(RenderMessage).new(256)
  @worker_context : Fiber::ExecutionContext::Parallel = Fiber::ExecutionContext::Parallel.new("mandelbrot-workers", 16)
  @job_id = Atomic(Int32).new(0)
  @running = false
  @render_pending = false
  @completed_workers = 0
  @active_workers = 0
  @completed_tiles = 0
  @total_tiles = 0
  @center_x = DEFAULT_CENTER_X
  @center_y = DEFAULT_CENTER_Y
  @scale = DEFAULT_SCALE
  @draw_x : Float64 = 0.0
  @draw_y : Float64 = 0.0
  @draw_width : Float64 = WIDTH.to_f64
  @draw_height : Float64 = HEIGHT.to_f64
  @drag_position : Tuple(Float64, Float64)?
  @pan_x = 0.0
  @pan_y = 0.0

  def initialize
    @handler = UIng::Area::Handler.new
    @area = UIng::Area.new(@handler)
    @window = UIng::Window.new("Mandelbrot Renderer", 1100, 850, margined: true)
    @workers_spinbox = UIng::Spinbox.new(1, 16, DEFAULT_WORKERS)
    @iterations_spinbox = UIng::Spinbox.new(50, 3000, DEFAULT_ITERS)
    @palette_combobox = UIng::Combobox.new(["Classic", "Fire", "Ice", "Gray"])
    @palette_combobox.selected = 0
    @progress_bar = UIng::ProgressBar.new
    @render_stop_button = UIng::Button.new("Render")
    @reset_button = UIng::Button.new("Reset")
    @status_label = UIng::Label.new("Idle")
    @image_buffer = UIng::ImageBuffer.new(WIDTH, HEIGHT)

    prepare_background
    setup_handlers
    setup_ui
  end

  private def setup_handlers
    @handler.draw do |_area, params|
      ctx = params.context

      ctx.fill_path(UIng::Area::Draw::Brush.new(:solid, 0.08, 0.09, 0.11, 1.0)) do |path|
        path.add_rectangle(0, 0, params.area_width, params.area_height)
      end

      scale = {params.area_width / WIDTH, params.area_height / HEIGHT}.min
      draw_width = WIDTH * scale
      draw_height = HEIGHT * scale
      x = (params.area_width - draw_width) / 2
      y = (params.area_height - draw_height) / 2
      @draw_x = x
      @draw_y = y
      @draw_width = draw_width
      @draw_height = draw_height

      next unless draw_width > 0 && draw_height > 0

      ctx.saved do
        ctx.clip_path { |path| path.add_rectangle(x, y, draw_width, draw_height) }
        ctx.draw_image(@image_buffer, x + @pan_x, y + @pan_y, draw_width, draw_height)
      end
    end

    @handler.mouse_event { |_area, event| pan(event) }

    @handler.scroll_event do |_area, event|
      next false if @drag_position || event.delta_y == 0

      factor = 1.1 ** event.delta_y.clamp(-10.0, 10.0)
      zoomed = zoom_at(event.x, event.y, factor)
      @render_pending = true if zoomed
      zoomed
    end

    @handler.mouse_crossed { |_area, _left| }
    @handler.drag_broken { |_area| @drag_position = nil }
    @handler.key_event { |_area, _event| false }
  end

  private def pan(event : UIng::Area::MouseEvent)
    if event.down == LEFT_BUTTON
      @drag_position = {event.x, event.y} if inside_image?(event.x, event.y)
    elsif previous = @drag_position
      if event.up != LEFT_BUTTON && (event.held1_to64 & 1_u64) == 0
        @drag_position = nil
        return
      end

      dx = event.x - previous[0]
      dy = event.y - previous[1]
      if dx != 0 || dy != 0
        @center_x -= dx / @draw_width * @scale * (WIDTH.to_f64 / HEIGHT)
        @center_y -= dy / @draw_height * @scale
        @pan_x += dx
        @pan_y += dy
        @render_pending = true
        @area.queue_redraw_all
      end
      @drag_position = event.up == LEFT_BUTTON ? nil : {event.x, event.y}
    end
  end

  private def setup_ui
    root = UIng::Box.new(:vertical)
    root.padded = true

    toolbar = UIng::Box.new(:horizontal)
    toolbar.padded = true
    toolbar.append(UIng::Label.new("Workers"), false)
    toolbar.append(@workers_spinbox, false)
    toolbar.append(UIng::Label.new("Iterations"), false)
    toolbar.append(@iterations_spinbox, false)
    toolbar.append(UIng::Label.new("Palette"), false)
    toolbar.append(@palette_combobox, false)
    toolbar.append(@render_stop_button, false)
    toolbar.append(@reset_button, false)

    status_bar = UIng::Box.new(:horizontal)
    status_bar.padded = true
    status_bar.append(@progress_bar, true)
    status_bar.append(@status_label, false)

    root.append(toolbar, false)
    root.append(status_bar, false)
    root.append(@area, true)

    @render_stop_button.on_clicked do
      if @running
        stop_render
      else
        start_render
      end
    end
    @palette_combobox.on_selected { start_render }
    @reset_button.on_clicked do
      @center_x = DEFAULT_CENTER_X
      @center_y = DEFAULT_CENTER_Y
      @scale = DEFAULT_SCALE
      start_render
    end

    @window.child = root
    @window.on_closing do
      stop_render
      UIng.quit
      true
    end
  end

  private def start_render
    stop_render
    drain_messages
    @drag_position = nil
    @pan_x = 0.0
    @pan_y = 0.0
    @image_buffer.update(@background)

    job_id = @job_id.add(1) + 1
    workers = @workers_spinbox.value.clamp(1, 16)
    config = RenderConfig.new(
      job_id,
      WIDTH,
      HEIGHT,
      @iterations_spinbox.value,
      @center_x,
      @center_y,
      @scale,
      @palette_combobox.selected || 0
    )

    tiles = build_tiles
    @total_tiles = tiles.size
    @completed_tiles = 0
    @completed_workers = 0
    @active_workers = workers
    @running = true
    @render_stop_button.text = "Stop"
    @progress_bar.value = 0
    @status_label.text = "Rendering 0/#{@total_tiles} tiles, #{workers} workers"
    @area.queue_redraw_all

    workers.times do |worker_id|
      worker_tiles = tiles.each_with_index.select { |_tile, index| index % workers == worker_id }.map(&.[0])
      @worker_context.spawn(name: "mandelbrot-#{worker_id}") do
        worker_tiles.each do |tile|
          break unless @job_id.get == job_id
          @messages.send(TileResult.new(job_id, tile, render_tile(config, tile)))
        end
        @messages.send(WorkerDone.new(job_id))
      end
    end
  end

  private def stop_render
    @render_pending = false
    return unless @running

    @job_id.add(1)
    @running = false
    @render_stop_button.text = "Render"
    @status_label.text = "Stopped at #{@completed_tiles}/#{@total_tiles} tiles"
  end

  private def build_tiles : Array(Tile)
    tiles = [] of Tile
    y = 0
    while y < HEIGHT
      x = 0
      tile_height = Math.min(TILE_SIZE, HEIGHT - y)
      while x < WIDTH
        tile_width = Math.min(TILE_SIZE, WIDTH - x)
        tiles << Tile.new(x, y, tile_width, tile_height)
        x += TILE_SIZE
      end
      y += TILE_SIZE
    end
    tiles
  end

  private def render_tile(config : RenderConfig, tile : Tile) : Bytes
    pixels = Bytes.new(tile.width * tile.height * 4)
    aspect = config.width.to_f64 / config.height

    tile.height.times do |local_y|
      py = tile.y + local_y
      cy = config.center_y + ((py.to_f64 / config.height) - 0.5) * config.scale

      tile.width.times do |local_x|
        px = tile.x + local_x
        cx = config.center_x + ((px.to_f64 / config.width) - 0.5) * config.scale * aspect
        iterations = mandelbrot_iterations(cx, cy, config.max_iterations)
        r, g, b = color_for(iterations, config.max_iterations, config.palette)
        offset = (local_y * tile.width + local_x) * 4
        pixels[offset] = r
        pixels[offset + 1] = g
        pixels[offset + 2] = b
        pixels[offset + 3] = 255_u8
      end
    end

    pixels
  end

  private def mandelbrot_iterations(cx : Float64, cy : Float64, max_iterations : Int32) : Int32
    x = 0.0
    y = 0.0
    iteration = 0

    while x * x + y * y <= 4.0 && iteration < max_iterations
      xt = x * x - y * y + cx
      y = 2.0 * x * y + cy
      x = xt
      iteration += 1
    end

    iteration
  end

  private def color_for(iteration : Int32, max_iterations : Int32, palette : Int32) : Tuple(UInt8, UInt8, UInt8)
    return {5_u8, 7_u8, 12_u8} if iteration >= max_iterations

    t = iteration.to_f64 / max_iterations
    case palette
    when 1
      r = (255.0 * Math.sqrt(t)).clamp(0.0, 255.0).to_u8
      g = (180.0 * t * t).clamp(0.0, 255.0).to_u8
      b = (40.0 * t * t * t).clamp(0.0, 255.0).to_u8
      {r, g, b}
    when 2
      r = (50.0 * t * t).clamp(0.0, 255.0).to_u8
      g = (180.0 * Math.sqrt(t)).clamp(0.0, 255.0).to_u8
      b = (255.0 * (0.25 + 0.75 * t)).clamp(0.0, 255.0).to_u8
      {r, g, b}
    when 3
      v = (255.0 * Math.sqrt(t)).clamp(0.0, 255.0).to_u8
      {v, v, v}
    else
      r = (9.0 * (1.0 - t) * t * t * t * 255.0).clamp(0.0, 255.0).to_u8
      g = (15.0 * (1.0 - t) * (1.0 - t) * t * t * 255.0).clamp(0.0, 255.0).to_u8
      b = (8.5 * (1.0 - t) * (1.0 - t) * (1.0 - t) * t * 255.0).clamp(0.0, 255.0).to_u8
      {r, g, b}
    end
  end

  private def prepare_background
    y = 0
    while y < HEIGHT
      x = 0
      while x < WIDTH
        offset = (y * WIDTH + x) * 4
        shade = ((x.to_f64 / WIDTH) * 20 + (y.to_f64 / HEIGHT) * 18).to_u8
        @background[offset] = 10_u8 + shade
        @background[offset + 1] = 12_u8 + shade
        @background[offset + 2] = 17_u8 + shade
        @background[offset + 3] = 255_u8
        x += 1
      end
      y += 1
    end
  end

  private def drain_messages
    loop do
      _, result = Channel.non_blocking_select(@messages.receive_select_action)
      break if result.is_a?(Channel::NotReady)
    end
  end

  private def process_messages
    dirty = false

    128.times do
      _, result = Channel.non_blocking_select(@messages.receive_select_action)
      break if result.is_a?(Channel::NotReady)

      case message = result.as(RenderMessage)
      when TileResult
        next unless message.job_id == @job_id.get

        tile = message.tile
        @image_buffer.update_rect(tile.x, tile.y, tile.width, tile.height, message.pixels)
        @completed_tiles += 1
        progress = ((@completed_tiles.to_f64 / @total_tiles) * 100).to_i.clamp(0, 100)
        @progress_bar.value = progress
        @status_label.text = "Rendering #{@completed_tiles}/#{@total_tiles} tiles"
        dirty = true
      when WorkerDone
        next unless message.job_id == @job_id.get

        @completed_workers += 1
        if @completed_workers >= @active_workers
          @running = false
          @render_stop_button.text = "Render"
          @progress_bar.value = 100
          @status_label.text = "Completed #{@total_tiles} tiles"
        end
      end
    end

    @area.queue_redraw_all if dirty
  end

  private def inside_image?(x : Float64, y : Float64) : Bool
    @draw_width > 0 && @draw_height > 0 &&
      x >= @draw_x && x <= @draw_x + @draw_width &&
      y >= @draw_y && y <= @draw_y + @draw_height
  end

  private def zoom_at(x : Float64, y : Float64, factor : Float64) : Bool
    return false unless inside_image?(x, y)

    scale = (@scale * factor).clamp(1e-13, 12.0)
    return false if scale == @scale

    # Keep the complex-plane coordinate under the pointer fixed while zooming.
    normalized_x = (x - @draw_x) / @draw_width
    normalized_y = (y - @draw_y) / @draw_height
    image_x = (normalized_x - 0.5) * (@scale - scale) * (WIDTH.to_f64 / HEIGHT)
    image_y = (normalized_y - 0.5) * (@scale - scale)
    @center_x += image_x
    @center_y += image_y
    @scale = scale
    true
  end

  def run
    timer = UIng.timer(16.milliseconds) do
      # Show a translated preview during dragging; render once it ends.
      start_render if @render_pending && @drag_position.nil?
      process_messages
      true
    end

    @window.show
    start_render
    UIng.main
  ensure
    timer.try &.stop
    stop_render
    @window.destroy unless @window.released?
    @image_buffer.free
  end
end

UIng.init do
  MandelbrotRenderer.new.run
end
