require "../../src/uing"

# A US ANSI keyboard and mouse, drawn entirely in one Area.
# Click anywhere in the black area to focus it, then use the physical keyboard.
# Only events delivered to this Area are shown; OS shortcuts may be intercepted.
# Nothing is drawn at rest. Held keys/buttons glow in color and fade on release.
# Rainbow trails show motion and pink trails show dragging inside the mouse;
# colored rings show the click count (up to 3). The outline pulses on enter/leave,
# and a coral cross marks interrupted capture.
# Area has no wheel-scroll callback (the wheel drawing shows the middle button).
module AreaEvents
  alias Draw = UIng::Area::Draw

  WIDTH  = 1144.0
  HEIGHT =  356.0
  UNIT   =   40.0
  FADE   = 0.7.seconds
  PINK   = {1.0, 0.18, 0.55}
  GOLD   = {1.0, 0.72, 0.12}
  CYAN   = {0.10, 0.82, 1.0}
  MINT   = {0.12, 1.0, 0.58}
  CORAL  = {1.0, 0.28, 0.16}

  PALETTE       = {PINK, GOLD, {0.55, 1.0, 0.16}, MINT, CYAN, {0.46, 0.25, 1.0}, {0.95, 0.20, 1.0}}
  BUTTON_COLORS = {PINK, GOLD, CYAN}

  record PointerSample, x : Float64, y : Float64, dragging : Bool, time : Time::Instant

  LABELS = {
    "escape" => "Esc", "backspace" => "Backspace", "tab" => "Tab",
    "caps" => "Caps", "enter" => "Enter", "shift" => "Shift",
    "ctrl" => "Ctrl", "alt" => "Alt", "super" => {% if flag?(:darwin) %} "Cmd" {% else %} "Win" {% end %},
    "menu" => "Menu", "space" => "", "print" => "PrtSc", "scroll" => "ScrLk",
    "pause" => "Pause", "insert" => "Ins", "home" => "Home", "pageup" => "PgUp",
    "delete" => "Del", "end" => "End", "pagedown" => "PgDn",
    "up" => "↑", "left" => "←", "down" => "↓", "right" => "→",
    "num" => "Num", "ndivide" => "/", "nmultiply" => "*", "nsubtract" => "−",
    "nadd" => "+", "nenter" => "Enter", "ndot" => ".",
  }
  SHIFTED   = "~!@#$%^&*()_+{}|:\"<>?".chars.zip("`1234567890-=[]\\;',./".chars).to_h
  MODIFIERS = {
    UIng::Modifiers::Ctrl  => "ctrl",
    UIng::Modifiers::Alt   => "alt",
    UIng::Modifiers::Shift => "shift",
    UIng::Modifiers::Super => "super",
  }

  def self.brush(color : Tuple(Float64, Float64, Float64), alpha : Float64 = 1.0)
    Draw::Brush.new(:solid, *color, alpha)
  end

  def self.spectrum(position : Float64) : Tuple(Float64, Float64, Float64)
    position = (position % 1.0) * PALETTE.size
    index = position.to_i
    mix = position - index
    first = PALETTE[index]
    second = PALETTE[(index + 1) % PALETTE.size]
    {
      first[0] + (second[0] - first[0]) * mix,
      first[1] + (second[1] - first[1]) * mix,
      first[2] + (second[2] - first[2]) * mix,
    }
  end

  def self.rounded_rectangle(x, y, width, height, radius) : Draw::Path
    path = Draw::Path.new(:winding)
    path.new_figure(x + radius, y)
    path.line_to(x + width - radius, y)
    path.arc_to(x + width - radius, y + radius, radius, -Math::PI / 2, Math::PI / 2, false)
    path.line_to(x + width, y + height - radius)
    path.arc_to(x + width - radius, y + height - radius, radius, 0, Math::PI / 2, false)
    path.line_to(x + radius, y + height)
    path.arc_to(x + radius, y + height - radius, radius, Math::PI / 2, Math::PI / 2, false)
    path.line_to(x, y + radius)
    path.arc_to(x + radius, y + radius, radius, Math::PI, Math::PI / 2, false)
    path.close_figure
    path.end_path
    path
  end

  def self.text_layout(label, width, font, color, alpha = 1.0) : Draw::TextLayout
    UIng::Area::AttributedString.open(label) do |text|
      text.set_attribute(UIng::Area::Attribute.new_color(*color, alpha), 0, text.len) unless label.empty?
      Draw::TextLayout.new(string: text, default_font: font, width: width, align: :center)
    end
  end

  def self.glow(ctx : Draw::Context, path : Draw::Path, color, light : Float64)
    return if light <= 0
    ctx.draw_stroke(path, brush(color, 0.025 * light), thickness: 18)
    ctx.draw_stroke(path, brush(color, 0.05 * light), thickness: 11)
    ctx.draw_stroke(path, brush(color, 0.12 * light), thickness: 5)
    ctx.draw_fill(path, brush(color, 0.24 * light))
    ctx.draw_stroke(path, brush(color, 0.95 * light), thickness: 1.3)
  end

  # Cache geometry and full-brightness labels; draw only active keys.
  class Key
    getter id : String
    @path : Draw::Path
    @text : Draw::TextLayout
    @text_y : Float64
    @color : Tuple(Float64, Float64, Float64)
    @label_color : Tuple(Float64, Float64, Float64)

    def initialize(@id : String, @label : String, @x : Float64, @y : Float64,
                   @width : Float64, height : Float64, @font : UIng::FontDescriptor)
      @path = AreaEvents.rounded_rectangle(@x, @y, @width, height, 5.0)
      @color = AreaEvents.spectrum((@x - 28) / (15 * UNIT) + (@y - 48) / (6 * UNIT) * 0.08)
      @label_color = @color.map { |component| 0.55 + component * 0.45 }
      @text = AreaEvents.text_layout(@label, @width, @font, @label_color)
      @text_y = @y + (height - @text.extents[1]) / 2
    end

    def draw(ctx : Draw::Context, light : Float64)
      return if light <= 0
      AreaEvents.glow(ctx, @path, @color, light)
      if light == 1.0
        ctx.draw_text_layout(@text, @x, @text_y)
      elsif !@label.empty?
        bright = AreaEvents.text_layout(@label, @width, @font, @label_color, light)
        begin
          ctx.draw_text_layout(bright, @x, @text_y)
        ensure
          bright.free
        end
      end
    end

    def free
      @path.free
      @text.free
    end
  end

  class Visualizer
    @keys = [] of Key
    @flashes = {} of String => Time::Instant
    @pressed = Set(String).new
    @held_buttons = 0_u64
    @inside = false
    @pointer : Tuple(Float64, Float64)?
    @trail = [] of PointerSample
    @click_count = 0
    @font = UIng::FontDescriptor.new(size: 12)
    @character_font = UIng::FontDescriptor.new(size: 18)
    @mouse_body = AreaEvents.rounded_rectangle(1004.0, 100.0, 108.0, 168.0, 49.0)
    @wheel = AreaEvents.rounded_rectangle(1051.0, 119.0, 14.0, 36.0, 7.0)
    @mouse_buttons : Array(Draw::Path)

    def initialize
      @mouse_buttons = [mouse_button(left: true), mouse_button(left: false)]
      build_keyboard
    end

    private def mouse_button(left : Bool) : Draw::Path
      path = Draw::Path.new(:winding)
      if left
        path.new_figure(1004, 180)
        path.line_to(1004, 149)
        path.arc_to(1053, 149, 49, Math::PI, Math::PI / 2, false)
        path.line_to(1058, 100)
      else
        path.new_figure(1058, 100)
        path.line_to(1063, 100)
        path.arc_to(1063, 149, 49, -Math::PI / 2, Math::PI / 2, false)
        path.line_to(1112, 180)
      end
      path.line_to(1058, 180)
      path.close_figure
      path.end_path
      path
    end

    private def add_key(id, x, y, width = 1.0, height = 1.0, label = nil)
      label ||= LABELS[id]? || (id.starts_with?('n') && id.size == 2 ? id[1..] : id.upcase)
      font = label.size == 1 ? @character_font : @font
      @keys << Key.new(id, label, 28.0 + x * UNIT, 48.0 + y * UNIT,
        width * UNIT - 4.0, height * UNIT - 4.0, font)
    end

    private def add_row(y, ids, widths = {} of String => Float64)
      x = 0.0
      ids.each do |id|
        width = widths[id]? || 1.0
        add_key(id, x, y, width)
        x += width
      end
    end

    private def build_keyboard
      add_key("escape", 0.0, 0.0)
      12.times do |i|
        add_key("f#{i + 1}", 2.0 + i + (i // 4) * 0.5, 0.0)
      end
      %w[print scroll pause].each_with_index { |id, i| add_key(id, 15.5 + i, 0.0) }

      add_row(1.5, %w[` 1 2 3 4 5 6 7 8 9 0 - = backspace], {"backspace" => 2.0})
      add_row(2.5, %w[tab q w e r t y u i o p] + ["[", "]", "\\"], {"tab" => 1.5, "\\" => 1.5})
      add_row(3.5, %w[caps a s d f g h j k l ; ' enter], {"caps" => 1.75, "enter" => 2.25})
      add_row(4.5, %w[shift z x c v b n m] + [",", ".", "/"], {"shift" => 2.25})
      add_key("shift", 12.25, 4.5, 2.75)
      add_row(5.5, %w[ctrl super alt space alt super menu ctrl], {
        "ctrl" => 1.25, "super" => 1.25, "alt" => 1.25, "space" => 6.25, "menu" => 1.25,
      })

      %w[insert home pageup].each_with_index { |id, i| add_key(id, 15.5 + i, 1.5) }
      %w[delete end pagedown].each_with_index { |id, i| add_key(id, 15.5 + i, 2.5) }
      add_key("up", 16.5, 4.5)
      %w[left down right].each_with_index { |id, i| add_key(id, 15.5 + i, 5.5) }

      %w[num ndivide nmultiply nsubtract].each_with_index { |id, i| add_key(id, 19.0 + i, 1.5) }
      [%w[n7 n8 n9], %w[n4 n5 n6], %w[n1 n2 n3]].each_with_index do |row, y|
        row.each_with_index { |id, x| add_key(id, 19.0 + x, 2.5 + y) }
      end
      add_key("nadd", 22.0, 2.5, 1.0, 2.0)
      add_key("nenter", 22.0, 4.5, 1.0, 2.0)
      add_key("n0", 19.0, 5.5, 2.0)
      add_key("ndot", 21.0, 5.5)
    end

    private def key_id(event : UIng::Area::KeyEvent) : String?
      if ext = event.ext_key
        return ext.to_s.downcase
      end
      return unless key = event.key
      case key
      when '\r', '\n'     then "enter"
      when '\t'           then "tab"
      when '\b', '\u007f' then "backspace"
      when '\u001b'       then "escape"
      when ' '            then "space"
      else
        (SHIFTED[key]? || key).downcase.to_s
      end
    end

    def key_event(event : UIng::Area::KeyEvent) : Bool
      id = key_id(event)
      now = Time.instant
      handled = !!id && @keys.any? { |key| key.id == id }
      set_pressed(id, !event.up?, now) if id && handled
      # libui reports modifier kinds, not their left/right physical locations.
      # Both matching keycaps light up. Lock keys, Print Screen, Pause and Menu
      # have no dedicated Area key codes and cannot light up.
      modifiers = event.modifiers
      modifiers |= event.modifier unless event.up?
      sync_modifiers(modifiers, now)
      handled || MODIFIERS.has_key?(event.modifier)
    end

    private def set_pressed(id : String, down : Bool, now : Time::Instant)
      if down
        @pressed.add(id)
        @flashes.delete(id)
      elsif @pressed.delete(id)
        @flashes[id] = now
      end
    end

    private def sync_modifiers(modifiers : UIng::Modifiers, now : Time::Instant)
      MODIFIERS.each do |flag, modifier_id|
        set_pressed(modifier_id, modifiers.includes?(flag), now)
      end
    end

    def mouse_event(event : UIng::Area::MouseEvent)
      now = Time.instant
      # Held1To64 excludes the button changing in this event. Add Down and
      # remove Up explicitly so button chords and releases during drags work.
      @held_buttons = event.held1_to64
      @held_buttons |= 1_u64 << (event.down - 1) if (1..64).includes?(event.down)
      @held_buttons &= ~(1_u64 << (event.up - 1)) if (1..64).includes?(event.up)
      (1..3).each do |button| # left = 1, middle = 2, right = 3
        set_pressed("mouse#{button}", (@held_buttons & (1_u64 << (button - 1))) != 0, now)
      end
      sync_modifiers(event.modifiers, now)
      update_pointer(event, now)
      if event.down != 0
        @click_count = event.count.clamp(1, 3)
        @flashes["click"] = now
      end
    end

    private def update_pointer(event : UIng::Area::MouseEvent, now : Time::Instant)
      return if event.area_width <= 0 || event.area_height <= 0
      @inside = (0...event.area_width).includes?(event.x) && (0...event.area_height).includes?(event.y)
      position = {
        1028.0 + 60.0 * (event.x / event.area_width).clamp(0.0, 1.0),
        198.0 + 46.0 * (event.y / event.area_height).clamp(0.0, 1.0),
      }
      if position != @pointer
        @trail << PointerSample.new(*position, @held_buttons != 0, now)
        @trail.shift if @trail.size > 120
        @flashes["motion"] = now
      end
      @pointer = position
    end

    def mouse_crossed(left : Bool)
      @inside = !left
      @flashes.delete(left ? "enter" : "leave")
      @flashes[left ? "leave" : "enter"] = Time.instant
      # Do not join positions on either side of a trip outside the Area.
      @trail.clear unless left
      @pointer = nil unless left
    end

    def drag_broken
      now = Time.instant
      @held_buttons = 0_u64
      (1..3).each { |button| set_pressed("mouse#{button}", false, now) }
      @trail.clear
      @flashes["broken"] = now
    end

    def focus_lost
      drag_broken unless @held_buttons == 0
      now = Time.instant
      @pressed.each { |id| @flashes[id] = now }
      @pressed.clear
      @inside = false
      @pointer = nil
    end

    def tick(area : UIng::Area)
      return if @flashes.empty? && @trail.empty?
      now = Time.instant
      @flashes.reject! { |_id, started| now - started >= FADE }
      @trail.reject! { |sample| now - sample.time >= FADE }
      # Also repaint the last frame so every expired glow is erased.
      area.queue_redraw_all
    end

    private def light(id : String, now : Time::Instant) : Float64
      return 1.0 if @pressed.includes?(id)
      return 0.0 unless started = @flashes[id]?
      fade(started, now)
    end

    private def fade(started : Time::Instant, now : Time::Instant) : Float64
      remaining = (1.0 - (now - started) / FADE).clamp(0.0, 1.0)
      remaining * remaining
    end

    def draw(params : UIng::Area::Draw::Params)
      ctx = params.context
      ctx.fill_path(AreaEvents.brush({0.0, 0.0, 0.0})) do |path|
        path.add_rectangle(0, 0, params.area_width, params.area_height)
      end
      return if params.area_width <= 0 || params.area_height <= 0

      # One shared transform preserves the keyboard layout when resizing.
      scale = Math.min(params.area_width / WIDTH, params.area_height / HEIGHT)
      matrix = Draw::Matrix.new.set_identity
      matrix.translate((params.area_width - WIDTH * scale) / 2, (params.area_height - HEIGHT * scale) / 2)
      matrix.scale(0, 0, scale, scale)
      ctx.save
      begin
        ctx.transform(matrix)
        now = Time.instant
        @keys.each { |key| key.draw(ctx, light(key.id, now)) }
        draw_mouse(ctx, now)
      ensure
        ctx.restore
      end
    end

    private def draw_mouse(ctx : Draw::Context, now : Time::Instant)
      {"enter" => MINT, "leave" => GOLD}.each do |id, color|
        pulse = light(id, now)
        if pulse > 0
          ctx.draw_stroke(@mouse_body, AreaEvents.brush(color, 0.07 * pulse), thickness: 10)
          ctx.draw_stroke(@mouse_body, AreaEvents.brush(color, 0.85 * pulse), thickness: 1.5)
        end
      end
      {1, 3}.each_with_index do |button, side|
        AreaEvents.glow(ctx, @mouse_buttons[side], BUTTON_COLORS[button - 1], light("mouse#{button}", now))
      end
      AreaEvents.glow(ctx, @wheel, GOLD, light("mouse2", now))
      draw_pointer(ctx, now)
    end

    private def pointer_color(x : Float64, y : Float64)
      AreaEvents.spectrum((x - 1028) / 60 + (y - 198) / 46 * 0.2)
    end

    private def draw_pointer(ctx : Draw::Context, now : Time::Instant)
      @trail.each_cons_pair do |previous, sample|
        color = sample.dragging ? PINK : pointer_color(sample.x, sample.y)
        ctx.stroke_path(AreaEvents.brush(color, 0.9 * fade(sample.time, now)), thickness: 2, cap: :round) do |path|
          path.new_figure(previous.x, previous.y)
          path.line_to(sample.x, sample.y)
        end
      end
      if (position = @pointer) && (@inside || @held_buttons != 0)
        x, y = position
        color = @held_buttons == 0 ? pointer_color(x, y) : PINK
        brightness = @held_buttons == 0 ? Math.max(light("motion", now), light("click", now)) : 1.0
        if brightness > 0
          ctx.fill_path(AreaEvents.brush(color, 0.15 * brightness)) do |path|
            path.new_figure_with_arc(x, y, 6, 0, 2 * Math::PI, false)
          end
          ctx.fill_path(AreaEvents.brush(color, brightness)) do |path|
            path.new_figure_with_arc(x, y, 2.5, 0, 2 * Math::PI, false)
          end
        end
        pulse = light("click", now)
        if pulse > 0
          @click_count.times do |i|
            ctx.stroke_path(AreaEvents.brush(BUTTON_COLORS[i], pulse * 0.9), thickness: 1.5) do |path|
              path.new_figure_with_arc(x, y, 5 + (1 - pulse) * 7 + i * 4, 0, 2 * Math::PI, false)
            end
          end
        end
      end
      broken = light("broken", now)
      if broken > 0
        ctx.stroke_path(AreaEvents.brush(CORAL, broken), thickness: 2, cap: :round) do |path|
          path.new_figure(1052, 214)
          path.line_to(1064, 226)
          path.new_figure(1064, 214)
          path.line_to(1052, 226)
        end
      end
    end

    def free
      @keys.each(&.free)
      @mouse_body.free
      @mouse_buttons.each(&.free)
      @wheel.free
    end
  end
end

UIng.init
visualizer = AreaEvents::Visualizer.new
handler = UIng::Area::Handler.new

handler.draw { |_area, params| visualizer.draw(params) }
handler.key_event do |area, event|
  handled = visualizer.key_event(event)
  area.queue_redraw_all if handled
  handled
end
handler.mouse_event do |area, event|
  visualizer.mouse_event(event)
  area.queue_redraw_all
end
handler.mouse_crossed do |area, left|
  visualizer.mouse_crossed(left)
  area.queue_redraw_all
end
handler.drag_broken do |area|
  visualizer.drag_broken
  area.queue_redraw_all
end

area = UIng::Area.new(handler)
window = UIng::Window.new("Area Events", AreaEvents::WIDTH.to_i, AreaEvents::HEIGHT.to_i)
window.child = area
window.on_focus_changed do |focused|
  unless focused || area.released?
    visualizer.focus_lost
    area.queue_redraw_all
  end
end
timer = UIng.timer(16.milliseconds) { visualizer.tick(area); true }
window.on_closing do
  timer.stop
  UIng.quit
  true
end
window.show

begin
  UIng.main
ensure
  timer.stop
  window.destroy unless window.released?
  visualizer.free
  UIng.uninit
end
