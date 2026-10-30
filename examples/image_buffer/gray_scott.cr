require "../../src/uing/crimage"

# du/dt = Du * laplacian(u) - u*v*v + feed*(1-u)
# dv/dt = Dv * laplacian(v) + u*v*v - (feed+kill)*v
module GrayScott
  SIZE    = 256
  CELLS   = SIZE * SIZE
  PRESETS = {
    {"Coral", 0.0545, 0.0620},
    {"Cell division", 0.0367, 0.0649},
    {"Spots", 0.0300, 0.0620},
    {"Labyrinth", 0.0290, 0.0570},
    {"Fingerprint", 0.0370, 0.0600},
    {"Worms", 0.0780, 0.0610},
    {"Holes", 0.0390, 0.0580},
    {"Waves", 0.0140, 0.0540},
    {"Chaos", 0.0260, 0.0510},
    {"U-skate", 0.0620, 0.0609},
  }
  # Sample CrImage gradients once; changing colors does not touch the fields.
  PALETTES = [
    {"Teal & Gold", ["#081020", "#10A0B4", "#FFE080"]},
    {"Ember", ["#100818", "#E04020", "#FFF0A0"]},
    {"Ocean", ["#040C24", "#1864C8", "#B0F8F0"]},
    {"Violet", ["#140828", "#9840D0", "#FFD0F0"]},
    {"Grayscale", ["#000000", "#808080", "#FFFFFF"]},
    {"Ink", ["#FAF8F0", "#746C64", "#141418"]},
  ].map do |name, colors|
    stops = colors.map_with_index do |hex, index|
      CrImage::Draw::ColorStop.new(index / (colors.size - 1).to_f64, CrImage::Color.parse(hex))
    end
    gradient = CrImage::Draw::LinearGradient.new(CrImage.point(0, 0), CrImage.point(255, 0), stops)
    {name, Array.new(256) { |index| gradient.color_at(index / 255.0).to_rgba8 }}
  end

  class Model
    getter feed : Float64 = PRESETS[0][1]
    getter kill : Float64 = PRESETS[0][2]
    getter steps = 0
    property palette : Array(CrImage::Color::RGBA) = PALETTES[0][1]

    def initialize
      @u = Slice(Float64).new(CELLS, 1.0)
      @v = Slice(Float64).new(CELLS, 0.0)
      @next_u = Slice(Float64).new(CELLS)
      @next_v = Slice(Float64).new(CELLS)
      @frame = CrImage.rgba(SIZE, SIZE)
      reset
    end

    def configure(index : Int32) : Nil
      _, feed, kill = PRESETS[index]
      configure(feed, kill)
      reset
    end

    # Manual adjustments keep the current field so patterns can evolve smoothly.
    def configure(feed : Float64, kill : Float64) : Nil
      unless (0.0..0.1).includes?(feed) && (0.0..0.1).includes?(kill)
        raise ArgumentError.new("feed and kill must be between 0 and 0.1")
      end
      @feed, @kill = feed, kill
    end

    def reset : Nil
      @u.fill(1.0)
      @v.fill(0.0)
      @steps = 0
      # Repeatable, scattered seeds make growth visible across the field.
      random = Random.new(42)
      12.times { seed(random.rand(10...SIZE - 10), random.rand(10...SIZE - 10)) }
    end

    def seed(cx : Int32, cy : Int32) : Nil
      radius = 4
      (cy - radius).clamp(0, SIZE - 1).upto((cy + radius).clamp(0, SIZE - 1)) do |y|
        (cx - radius).clamp(0, SIZE - 1).upto((cx + radius).clamp(0, SIZE - 1)) do |x|
          next if (x - cx) ** 2 + (y - cy) ** 2 > radius ** 2
          i = y * SIZE + x
          @u[i] = 0.5
          # A strong seed also survives the higher feed rates in Worms/U-skate.
          @v[i] = 0.5
        end
      end
    end

    def advance(count : Int32 = 4) : Nil
      count.times do
        u, v = @u, @v
        next_u, next_v = @next_u, @next_v
        SIZE.times do |y|
          row = y * SIZE
          above = (y == 0 ? SIZE - 1 : y - 1) * SIZE
          below = (y == SIZE - 1 ? 0 : y + 1) * SIZE
          SIZE.times do |x|
            left = x == 0 ? SIZE - 1 : x - 1
            right = x == SIZE - 1 ? 0 : x + 1
            i = row + x
            a, b = u[i], v[i]
            # Periodic boundaries; 3x3 Laplacian: center -1, edges .2, corners .05.
            lap_u = -a + 0.2 * (u[row + left] + u[row + right] + u[above + x] + u[below + x]) +
                    0.05 * (u[above + left] + u[above + right] + u[below + left] + u[below + right])
            lap_v = -b + 0.2 * (v[row + left] + v[row + right] + v[above + x] + v[below + x]) +
                    0.05 * (v[above + left] + v[above + right] + v[below + left] + v[below + right])
            reaction = a * b * b
            # Du = 1, Dv = .5, dt = 1. Read the old fields for every cell,
            # then swap buffers so updates are independent of traversal order.
            next_u[i] = (a + lap_u - reaction + @feed * (1.0 - a)).clamp(0.0, 1.0)
            next_v[i] = (b + 0.5 * lap_v + reaction - (@feed + @kill) * b).clamp(0.0, 1.0)
          end
        end
        @u, @next_u = @next_u, @u
        @v, @next_v = @next_v, @v
      end
      @steps += count
    end

    # Reuse an opaque CrImage frame; ImageBuffer#update copies its RGBA pixels.
    def render : Bytes
      SIZE.times do |y|
        SIZE.times do |x|
          color = @palette[(@v[y * SIZE + x] * 3.0 * 255).clamp(0.0, 255.0).to_i]
          @frame.set_rgba(x, y, color)
        end
      end
      @frame.pix
    end
  end

  def self.viewport(width : Float64, height : Float64) : {Float64, Float64, Float64}
    size = Math.min(width, height)
    {(width - size) / 2, (height - size) / 2, size}
  end

  def self.seed_position(event : UIng::Area::MouseEvent) : {Int32, Int32}?
    return unless event.down == 1 || (event.held1_to64 & 1_u64) != 0
    x, y, size = viewport(event.area_width, event.area_height)
    return unless size > 0 && event.x >= x && event.y >= y && event.x < x + size && event.y < y + size
    {((event.x - x) * SIZE / size).to_i, ((event.y - y) * SIZE / size).to_i}
  end

  def self.run : Nil
    UIng.init do
      # Both the timer and the window are closed before open frees the image,
      # and the image is freed before UIng.init's block uninitializes libui-ng.
      UIng::ImageBuffer.open(SIZE, SIZE) do |image|
        model = Model.new
        image.update(model.render)
        window = UIng::Window.new("Gray–Scott reaction–diffusion", 480, 540, margined: true)
        timer : UIng::Timer? = nil
        begin
          paused = false
          frames = 0
          area = UIng::Area.new
          pause = UIng::Button.new("Pause")
          reset = UIng::Button.new("Reset")
          presets = UIng::Combobox.new(PRESETS.map(&.[0]).to_a + ["Custom"])
          presets.selected = 0
          palettes = UIng::Combobox.new(PALETTES.map(&.[0]))
          palettes.selected = 0
          palettes.tooltip = "Color palette (keeps the current pattern)"
          feed = UIng::Slider.new(0, 1000, (model.feed * 10_000).round.to_i)
          kill = UIng::Slider.new(0, 1000, (model.kill * 10_000).round.to_i)
          # Native slider tooltips show unscaled integers; the labels show rates.
          feed.has_tool_tip = false
          kill.has_tool_tip = false
          feed_label = UIng::Label.new("")
          kill_label = UIng::Label.new("")
          refresh_parameters = -> {
            feed.value = (model.feed * 10_000).round.to_i
            kill.value = (model.kill * 10_000).round.to_i
            feed_label.text = "F = %.4f" % model.feed
            kill_label.text = "k = %.4f" % model.kill
          }
          refresh_parameters.call
          status = UIng::Label.new("")
          refresh_status = -> { status.text = "Steps: #{model.steps}   ·   Drag to add V" }
          refresh_status.call

          background = UIng::Area::Draw::Brush.solid(model.palette.first)
          area.on_draw do |params|
            x, y, size = viewport(params.area_width, params.area_height)
            next unless size > 0
            context = params.context
            context.fill_path(background) do |path|
              path.add_rectangle(0, 0, params.area_width, params.area_height)
            end
            context.draw_image(image, x, y, size, size, interpolation: :smooth)
          end
          area.on_mouse_event do |event|
            next unless position = seed_position(event)
            model.seed(*position)
            image.update(model.render)
            area.queue_redraw_all
          end

          pause.on_clicked do
            paused = !paused
            pause.text = paused ? "Resume" : "Pause"
          end
          reset.on_clicked do
            model.reset
            image.update(model.render)
            refresh_status.call
            area.queue_redraw_all
          end
          presets.on_selected do |index|
            next if index == PRESETS.size # Custom keeps the manually chosen rates.
            model.configure(index)
            refresh_parameters.call
            image.update(model.render)
            refresh_status.call
            area.queue_redraw_all
          end
          palettes.on_selected do |index|
            model.palette = PALETTES[index][1]
            background = UIng::Area::Draw::Brush.solid(model.palette.first)
            image.update(model.render)
            area.queue_redraw_all
          end
          adjust_parameters = ->(_value : Int32) {
            model.configure(feed.value / 10_000.0, kill.value / 10_000.0)
            presets.selected = PRESETS.index { |preset| preset[1] == model.feed && preset[2] == model.kill } || PRESETS.size
            refresh_parameters.call
          }
          feed.on_changed(&adjust_parameters)
          kill.on_changed(&adjust_parameters)

          controls = UIng::Box.new(:horizontal, padded: true)
          controls.append(presets, true)
          controls.append(palettes, true)
          controls.append(pause)
          controls.append(reset)
          parameters = UIng::Box.new(:horizontal, padded: true)
          parameters.append(feed_label)
          parameters.append(feed, true)
          parameters.append(kill_label)
          parameters.append(kill, true)
          layout = UIng::Box.new(:vertical, padded: true)
          layout.append(controls)
          layout.append(parameters)
          layout.append(area, true)
          layout.append(status)
          window.child = layout
          window.on_closing do
            timer.try &.stop
            UIng.quit
            true
          end
          timer = UIng.timer(16.milliseconds) do
            unless paused
              model.advance
              image.update(model.render)
              area.queue_redraw_all
              frames += 1
              refresh_status.call if frames % 20 == 0
            end
            true
          end
          window.show
          UIng.main
        ensure
          timer.try &.stop
          window.destroy
        end
      end
    end
  end
end

GrayScott.run
