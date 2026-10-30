require "../../src/uing/crimage"

# Run with: crystal run --release examples/image_buffer/stable_fluids.cr
# Requires ImageBuffer-capable libui-ng (dev da49cf29 or later).
# See Jos Stam, Real-Time Fluid Dynamics for Games (2003):
# https://www.dgp.toronto.edu/people/stam/reality/Research/pdf/GDC03.pdf
module StableFluids
  SIZE       = 160
  DT         = 1.0 / 60.0
  BACKGROUND = CrImage::Color.parse("#060606")

  # Three separately transported inks allow recoloring an existing flow.
  PALETTES = [
    {"Aurora", ["#0FF2D1", "#8C26FF", "#FF8C1A"]},
    {"Lagoon", ["#058CFF", "#05FFA6", "#66BFFF"]},
    {"Ember", ["#FF1F08", "#FF8C0A", "#A60F4D"]},
  ].map { |name, colors| {name, colors.map { |hex| CrImage::Color.parse(hex) }} }

  class Model
    @dye : Array(Slice(Float64))
    @previous_dye : Array(Slice(Float64))
    @tone : Array(Float64)
    @vignette : Array(Float64)

    getter size : Int32
    getter time = 0.0
    property swirl = 18.0
    property? automatic = true
    property palette = 0

    def initialize(@size : Int32 = SIZE)
      raise ArgumentError.new("grid size must be between 8 and 512") unless (8..512).includes?(@size)
      @stride = @size + 2
      cells = @stride * @stride
      @u = Slice(Float64).new(cells)
      @v = Slice(Float64).new(cells)
      @previous_u = Slice(Float64).new(cells)
      @previous_v = Slice(Float64).new(cells)
      @pressure = Slice(Float64).new(cells)
      @divergence = Slice(Float64).new(cells)
      @curl = Slice(Float64).new(cells)
      @dye = Array.new(3) { Slice(Float64).new(cells) }
      @previous_dye = Array.new(3) { Slice(Float64).new(cells) }
      @frame = CrImage.rgba(@size, @size)
      # Tone mapping and a subtle vignette keep wisps luminous on a dark field.
      @tone = Array.new(4096) { |i| Math.sqrt(1.0 - Math.exp(-i / 512.0)) }
      @vignette = Array.new(@size * @size) do |i|
        x = (i % @size + 0.5) / @size - 0.5
        y = (i // @size + 0.5) / @size - 0.5
        1.0 - 0.6 * (x * x + y * y)
      end
    end

    def clear : Nil
      [@u, @v, @previous_u, @previous_v, @pressure, @divergence, @curl].each(&.fill(0.0))
      @dye.each(&.fill(0.0))
      @previous_dye.each(&.fill(0.0))
      @time = 0.0
    end

    # Coordinates and velocities are in a unit square, with y pointing down.
    def splat(x : Float64, y : Float64, vx : Float64, vy : Float64,
              ink : Int32, amount : Float64 = 0.6, radius : Float64 = 0.025) : Nil
      cx, cy = 1.0 + x * (@size - 1), 1.0 + y * (@size - 1)
      r = Math.max(radius * @size, 1.0)
      reach = (r * 2.5).ceil.to_i
      (cy.to_i - reach).clamp(1, @size).upto((cy.to_i + reach).clamp(1, @size)) do |row|
        (cx.to_i - reach).clamp(1, @size).upto((cx.to_i + reach).clamp(1, @size)) do |column|
          weight = Math.exp(-((column - cx) ** 2 + (row - cy) ** 2) / (r * r))
          i = column + row * @stride
          @u[i] = (@u[i] + vx * weight).clamp(-2.0, 2.0)
          @v[i] = (@v[i] + vy * weight).clamp(-2.0, 2.0)
          @dye[ink][i] = Math.min(@dye[ink][i] + amount * weight, 8.0)
        end
      end
    end

    def advance : Nil
      emit if @automatic
      confine
      # Implicit viscosity, pressure projection, then semi-Lagrangian transport.
      a = DT * 0.00001 * @size * @size
      @previous_u.copy_from(@u)
      @previous_v.copy_from(@v)
      solve(1, @u, @previous_u, a, 1.0 + 4.0 * a, 8)
      solve(2, @v, @previous_v, a, 1.0 + 4.0 * a, 8)
      project
      @previous_u.copy_from(@u)
      @previous_v.copy_from(@v)
      advect(1, @u, @previous_u, @previous_u, @previous_v)
      advect(2, @v, @previous_v, @previous_u, @previous_v)
      project
      3.times do |channel|
        @dye[channel], @previous_dye[channel] = @previous_dye[channel], @dye[channel]
        advect(0, @dye[channel], @previous_dye[channel], @u, @v)
        @dye[channel].map! { |value| value * 0.992 }
      end
      @time += DT
    end

    private def emit : Nil
      3.times do |ink|
        angle = ink * Math::PI * 2.0 / 3.0 + @time * 0.18
        x = 0.5 + 0.27 * Math.cos(angle)
        y = 0.5 + 0.27 * Math.sin(angle)
        direction = angle + Math::PI * 0.78 + 0.4 * Math.sin(@time * 0.9 + ink)
        splat(x, y, Math.cos(direction) * 0.035, Math.sin(direction) * 0.035,
          ink, 0.16, 0.018)
      end
    end

    # Vorticity confinement restores small curls lost to numerical diffusion.
    private def confine : Nil
      1.upto(@size) do |y|
        1.upto(@size) do |x|
          i = x + y * @stride
          @curl[i] = 0.5 * (@v[i + 1] - @v[i - 1] - @u[i + @stride] + @u[i - @stride])
        end
      end
      boundary(0, @curl)
      1.upto(@size) do |y|
        1.upto(@size) do |x|
          i = x + y * @stride
          nx = @curl[i + 1].abs - @curl[i - 1].abs
          ny = @curl[i + @stride].abs - @curl[i - @stride].abs
          length = Math.sqrt(nx * nx + ny * ny) + 1e-12
          force = DT * @swirl * @curl[i] / length
          @u[i] = ((@u[i] + ny * force) * 0.999).clamp(-2.0, 2.0)
          @v[i] = ((@v[i] - nx * force) * 0.999).clamp(-2.0, 2.0)
        end
      end
      boundary(1, @u)
      boundary(2, @v)
    end

    private def solve(kind : Int32, field : Slice(Float64), source : Slice(Float64),
                      a : Float64, divisor : Float64, iterations : Int32 = 20) : Nil
      iterations.times do
        1.upto(@size) do |y|
          1.upto(@size) do |x|
            i = x + y * @stride
            field[i] = (source[i] + a * (field[i - 1] + field[i + 1] +
                                         field[i - @stride] + field[i + @stride])) / divisor
          end
        end
        boundary(kind, field)
      end
    end

    private def project : Nil
      @pressure.fill(0.0)
      1.upto(@size) do |y|
        1.upto(@size) do |x|
          i = x + y * @stride
          @divergence[i] = -0.5 * (@u[i + 1] - @u[i - 1] + @v[i + @stride] - @v[i - @stride]) / @size
        end
      end
      boundary(0, @divergence)
      boundary(0, @pressure)
      solve(0, @pressure, @divergence, 1.0, 4.0)
      1.upto(@size) do |y|
        1.upto(@size) do |x|
          i = x + y * @stride
          @u[i] -= 0.5 * @size * (@pressure[i + 1] - @pressure[i - 1])
          @v[i] -= 0.5 * @size * (@pressure[i + @stride] - @pressure[i - @stride])
        end
      end
      boundary(1, @u)
      boundary(2, @v)
    end

    private def advect(kind : Int32, field : Slice(Float64), source : Slice(Float64),
                       u : Slice(Float64), v : Slice(Float64)) : Nil
      step = DT * @size
      1.upto(@size) do |y|
        1.upto(@size) do |x|
          i = x + y * @stride
          px = (x - step * u[i]).clamp(0.5, @size + 0.5)
          py = (y - step * v[i]).clamp(0.5, @size + 0.5)
          x0, y0 = px.to_i, py.to_i
          sx, sy = px - x0, py - y0
          top = x0 + y0 * @stride
          bottom = top + @stride
          field[i] = (1.0 - sy) * ((1.0 - sx) * source[top] + sx * source[top + 1]) +
                     sy * ((1.0 - sx) * source[bottom] + sx * source[bottom + 1])
        end
      end
      boundary(kind, field)
    end

    # Closed walls: reflect the normal velocity, copy scalars/tangent velocity.
    private def boundary(kind : Int32, field : Slice(Float64)) : Nil
      1.upto(@size) do |i|
        field[i * @stride] = (kind == 1 ? -1.0 : 1.0) * field[1 + i * @stride]
        field[@size + 1 + i * @stride] = (kind == 1 ? -1.0 : 1.0) * field[@size + i * @stride]
        field[i] = (kind == 2 ? -1.0 : 1.0) * field[i + @stride]
        field[i + (@size + 1) * @stride] = (kind == 2 ? -1.0 : 1.0) * field[i + @size * @stride]
      end
      field[0] = 0.5 * (field[1] + field[@stride])
      field[@size + 1] = 0.5 * (field[@size] + field[@size + 1 + @stride])
      bottom = (@size + 1) * @stride
      field[bottom] = 0.5 * (field[bottom + 1] + field[bottom - @stride])
      field[bottom + @size + 1] = 0.5 * (field[bottom + @size] + field[bottom + @size + 1 - @stride])
    end

    private def tone_map(light : Float64, shade : Float64) : UInt8
      level = @tone[(light * 512 / 255).clamp(0.0, 4095.0).to_i]
      (BACKGROUND.r + level * (255 - BACKGROUND.r) * shade).to_u8
    end

    # Reuse an opaque CrImage frame; ImageBuffer#update copies its RGBA pixels.
    def render : CrImage::RGBA
      colors = PALETTES[@palette][1]
      @size.times do |y|
        @size.times do |x|
          i = x + 1 + (y + 1) * @stride
          pixel = x + y * @size
          a, b, c = @dye[0][i], @dye[1][i], @dye[2][i]
          shade = @vignette[pixel]
          color = CrImage::Color::RGBA.from_rgb(
            tone_map(a * colors[0].r + b * colors[1].r + c * colors[2].r, shade),
            tone_map(a * colors[0].g + b * colors[1].g + c * colors[2].g, shade),
            tone_map(a * colors[0].b + b * colors[1].b + c * colors[2].b, shade))
          @frame.set_rgba(x, y, color)
        end
      end
      @frame
    end
  end

  def self.viewport(width : Float64, height : Float64) : {Float64, Float64, Float64}
    size = Math.min(width, height)
    {(width - size) / 2, (height - size) / 2, size}
  end

  class Painter
    @previous : Tuple(Float64, Float64)?
    @ink = 0

    def initialize(@model : Model)
    end

    def reset : Nil
      @previous = nil
    end

    def paint(event : UIng::Area::MouseEvent) : Bool
      x, y, size = StableFluids.viewport(event.area_width, event.area_height)
      held = event.down == 1 || (event.held1_to64 & 1_u64) != 0
      unless held && event.up != 1 && size > 0 &&
             event.x >= x && event.y >= y && event.x < x + size && event.y < y + size
        reset
        return false
      end
      px, py = (event.x - x) / size, (event.y - y) / size
      if event.down == 1
        reset
        @ink = (@ink + 1) % 3
      end
      last = @previous
      from_x = last ? last[0] : px
      from_y = last ? last[1] : py
      dx, dy = px - from_x, py - from_y
      # Interpolate long strokes so fast drags leave a continuous ribbon.
      samples = (Math.sqrt(dx * dx + dy * dy) * SIZE / 2).ceil.to_i.clamp(1, SIZE)
      samples.times do |index|
        t = (index + 1.0) / samples
        @model.splat(from_x + dx * t, from_y + dy * t,
          (dx * 8).clamp(-0.4, 0.4) / samples,
          (dy * 8).clamp(-0.4, 0.4) / samples,
          @ink, 0.65 / Math.sqrt(samples.to_f64))
      end
      @previous = {px, py}
      true
    end
  end

  def self.run : Nil
    UIng.init do
      model = Model.new
      # Start with developed curls rather than an empty field.
      240.times { model.advance }
      UIng::ImageBuffer.open(model.render) do |image|
        window = UIng::Window.new("Stable Fluids · Ink in motion", 760, 850, margined: true)
        timer : UIng::Timer? = nil
        begin
          area = UIng::Area.new
          paused = false
          painter = Painter.new(model)
          frames = 0
          measured_at = Time.instant
          pause = UIng::Button.new("Pause")
          clear = UIng::Button.new("Clear")
          automatic = UIng::Checkbox.new("Auto ink")
          automatic.checked = true
          palettes = UIng::Combobox.new(PALETTES.map(&.[0]).to_a)
          palettes.selected = 0
          swirl = UIng::Slider.new(0, 40, model.swirl.to_i)
          swirl.has_tool_tip = false
          swirl_label = UIng::Label.new("Swirl: #{swirl.value}")
          status = UIng::Label.new("Drag to pour ink and stir · #{SIZE} × #{SIZE} cells")
          redraw = -> {
            image.update(model.render)
            area.queue_redraw_all
          }
          background = UIng::Area::Draw::Brush.solid(BACKGROUND)
          area.on_draw do |params|
            x, y, size = viewport(params.area_width, params.area_height)
            next unless size > 0
            params.context.fill_path(background) do |path|
              path.add_rectangle(0, 0, params.area_width, params.area_height)
            end
            params.context.draw_image(image, x, y, size, size, interpolation: :smooth)
          end
          area.on_mouse_event do |event|
            redraw.call if painter.paint(event)
          end
          area.on_mouse_crossed { |_left| painter.reset }
          area.on_drag_broken { painter.reset }
          pause.on_clicked do
            paused = !paused
            painter.reset
            pause.text = paused ? "Resume" : "Pause"
          end
          clear.on_clicked do
            model.clear
            painter.reset
            redraw.call
          end
          automatic.on_toggled { |enabled| model.automatic = enabled }
          palettes.on_selected do |index|
            model.palette = index
            redraw.call
          end
          swirl.on_changed do |value|
            model.swirl = value.to_f64
            swirl_label.text = "Swirl: #{value}"
          end
          controls = UIng::Box.new(:horizontal, padded: true)
          controls.append(palettes, true)
          controls.append(automatic)
          controls.append(pause)
          controls.append(clear)
          parameters = UIng::Box.new(:horizontal, padded: true)
          parameters.append(swirl_label)
          parameters.append(swirl, true)
          layout = UIng::Box.new(:vertical, padded: true)
          layout.append(UIng::Label.new("STABLE FLUIDS   /   Ink in motion"))
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
          UIng.on_should_quit do
            timer.try &.stop
            UIng.quit
            true
          end
          # A fixed simulation step keeps motion predictable under load.
          timer = UIng.timer(16.milliseconds) do
            unless paused
              model.advance
              redraw.call
            end
            frames += 1
            now = Time.instant
            elapsed = (now - measured_at).total_seconds
            if elapsed >= 1.0
              status.text = "Drag to pour ink and stir · #{SIZE} × #{SIZE} cells · #{paused ? "Paused" : "#{(frames / elapsed).round.to_i} fps"}"
              frames = 0
              measured_at = now
            end
            true
          end
          window.show
          UIng.main
        ensure
          timer.try &.stop
          UIng.clear_on_should_quit
          window.destroy unless window.released?
        end
      end
    end
  end
end

StableFluids.run
