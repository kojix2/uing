require "../../src/uing"
require "math"

# Run with:
#   crystal run -Dexecution_context -Dpreview_mt examples/MT/mandelbrot.cr

WIDTH           = 1200
HEIGHT          =  900
TILE_SIZE       =   32
DEFAULT_ITERS   =  500
DEFAULT_WORKERS =    4
LEFT_BUTTON     =    1
RIGHT_BUTTON    =    3
ZOOM_FACTOR     =  2.0

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

  @pixels = Bytes.new(WIDTH * HEIGHT * 4, 0_u8)
  @messages = Channel(RenderMessage).new(256)
  @worker_context : Fiber::ExecutionContext::Parallel = Fiber::ExecutionContext::Parallel.new("mandelbrot-workers", 16)
  @job_id = Atomic(Int32).new(0)
  @running = false
  @completed_workers = 0
  @active_workers = 0
  @completed_tiles = 0
  @total_tiles = 0
  @center_x = -0.5
  @center_y = 0.0
  @scale = 3.0
  @draw_x : Float64 = 0.0
  @draw_y : Float64 = 0.0
  @draw_width : Float64 = WIDTH.to_f64
  @draw_height : Float64 = HEIGHT.to_f64

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

    clear_pixels
    setup_handlers
    setup_ui
  end

  private def setup_handlers
    @handler.draw do |_, params|
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

      image = UIng::Image.new(WIDTH, HEIGHT)
      image.append(@pixels, WIDTH, HEIGHT, WIDTH * 4)
      ctx.draw_image(image, x, y, draw_width, draw_height)
      image.free
    end

    @handler.mouse_event do |_, event|
      case event.down
      when LEFT_BUTTON
        zoom_at(event.x, event.y, 1.0 / ZOOM_FACTOR)
        start_render
      when RIGHT_BUTTON
        zoom_at(event.x, event.y, ZOOM_FACTOR)
        start_render
      end
    end

    @handler.mouse_crossed { |_, _| }
    @handler.drag_broken { |_| }
    @handler.key_event { |_, _| false }
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
      @center_x = -0.5
      @center_y = 0.0
      @scale = 3.0
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
    clear_pixels

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
      @palette_combobox.selected
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
      worker_tiles = tiles.each_with_index.select { |_, index| index % workers == worker_id }.map(&.[0])
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

  private def copy_tile(result : TileResult)
    tile = result.tile
    tile.height.times do |local_y|
      source = local_y * tile.width * 4
      target = ((tile.y + local_y) * WIDTH + tile.x) * 4
      @pixels[target, tile.width * 4].copy_from(result.pixels[source, tile.width * 4])
    end
  end

  private def clear_pixels
    y = 0
    while y < HEIGHT
      x = 0
      while x < WIDTH
        offset = (y * WIDTH + x) * 4
        shade = ((x.to_f64 / WIDTH) * 20 + (y.to_f64 / HEIGHT) * 18).to_u8
        @pixels[offset] = 10_u8 + shade
        @pixels[offset + 1] = 12_u8 + shade
        @pixels[offset + 2] = 17_u8 + shade
        @pixels[offset + 3] = 255_u8
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

        copy_tile(message)
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

  private def zoom_at(x : Float64, y : Float64, factor : Float64)
    return unless x >= @draw_x && x <= @draw_x + @draw_width
    return unless y >= @draw_y && y <= @draw_y + @draw_height

    normalized_x = (x - @draw_x) / @draw_width
    normalized_y = (y - @draw_y) / @draw_height
    image_x = (normalized_x - 0.5) * @scale * (WIDTH.to_f64 / HEIGHT)
    image_y = (normalized_y - 0.5) * @scale
    @center_x += image_x
    @center_y += image_y
    @scale *= factor
  end

  def run
    UIng.timer(16) do
      process_messages
      1
    end

    @window.show
    start_render
    UIng.main
  end
end

UIng.init
MandelbrotRenderer.new.run
UIng.uninit
