require "../../src/uing"

# A US ANSI keyboard and mouse, drawn entirely in one Area.
# Click the Area to focus it, then use the physical keyboard.
# Only events delivered to this Area are shown; OS shortcuts may be intercepted.
# The circular controls switch light/dark mode and persistent key/mouse outlines.
# Keys and mouse outlines are visible at rest; held inputs glow and fade on release.
# Rainbow trails show motion and pink trails show dragging inside the mouse;
# colored rings show the click count (up to 3). Multiple clicks also send
# expanding rings from the matching mouse button. Scroll chevrons show direction.
# The outline pulses on enter/leave, and a coral cross marks interrupted capture.
# The wheel glows on scroll and middle-button presses.
module AreaEvents
  alias Draw = UIng::Area::Draw

  WIDTH          = 1144.0
  HEIGHT         =  356.0
  UNIT           =   40.0
  FADE           = 0.7.seconds
  FEEDBACK_FADE  = 1.2.seconds
  PINK           = {1.0, 0.18, 0.55}
  GOLD           = {1.0, 0.72, 0.12}
  CYAN           = {0.10, 0.82, 1.0}
  MINT           = {0.12, 1.0, 0.58}
  CORAL          = {1.0, 0.28, 0.16}
  LIGHT_SUN      = {1.0, 0.84, 0.0}
  LIGHT_PIN      = {0.27, 0.32, 0.80}
  THEME_X        = 1028.0
  VISIBILITY_X   = 1088.0
  CONTROL_Y      =   53.0
  CONTROL_RADIUS =   19.0
  POINTER_X      = 1028.0
  POINTER_Y      =  198.0
  POINTER_WIDTH  =   60.0
  POINTER_HEIGHT =   46.0

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

  def self.gray(value : Float64) : Tuple(Float64, Float64, Float64)
    {value, value, value}
  end

  # Drawing and hit testing must use the same scale and letterbox offsets.
  def self.viewport(width : Float64, height : Float64) : {Float64, Float64, Float64}
    scale = Math.min(width / WIDTH, height / HEIGHT)
    {scale, (width - WIDTH * scale) / 2, (height - HEIGHT * scale) / 2}
  end

  def self.vertical_gradient(x : Float64, y : Float64, height : Float64,
                             top : Tuple(Float64, Float64, Float64),
                             bottom : Tuple(Float64, Float64, Float64), alpha : Float64 = 1.0) : Draw::Brush
    stops = [
      Draw::Brush::GradientStop.new(0, *top, alpha),
      Draw::Brush::GradientStop.new(1, *bottom, alpha),
    ]
    Draw::Brush.new(:linear_gradient, x0: x, y0: y, x1: x, y1: y + height, stops: stops)
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
    path.add_rounded_rectangle(x, y, width, height, radius)
    path.end_path
    path
  end

  def self.circle(x, y, radius) : Draw::Path
    path = Draw::Path.new(:winding)
    path.new_figure_with_arc(x, y, radius, 0, 2 * Math::PI, false)
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

  # Cache geometry, gradients, and labels for both themes.
  class Key
    getter id : String
    @path : Draw::Path
    @text_y : Float64
    @color : Tuple(Float64, Float64, Float64)
    @active_top : Tuple(Float64, Float64, Float64)
    @active_bottom : Tuple(Float64, Float64, Float64)
    @label_color : Tuple(Float64, Float64, Float64)
    @light_label_color : Tuple(Float64, Float64, Float64)

    def initialize(@id : String, @label : String, @x : Float64, @y : Float64,
                   @width : Float64, @height : Float64, @font : UIng::FontDescriptor)
      @path = AreaEvents.rounded_rectangle(@x, @y, @width, @height, 5.0)
      @color = AreaEvents.spectrum((@x - 28) / (15 * UNIT) + (@y - 48) / (6 * UNIT) * 0.08)
      @active_top = @color.map { |component| 0.08 + component * 0.58 }
      @active_bottom = @color.map { |component| 0.40 + component * 0.60 }
      @gradients = {
        dark_idle:  AreaEvents.vertical_gradient(@x, @y, @height, AreaEvents.gray(0.07), AreaEvents.gray(0.20)),
        light_idle: AreaEvents.vertical_gradient(@x, @y, @height, AreaEvents.gray(0.90), AreaEvents.gray(1.0)),
        active:     AreaEvents.vertical_gradient(@x, @y, @height, @active_top, @active_bottom),
      }
      @label_color = @color.map { |component| 0.55 + component * 0.45 }
      @light_label_color = @color.map { |component| component * 0.45 }
      @texts = {
        dark:       AreaEvents.text_layout(@label, @width, @font, @label_color),
        light:      AreaEvents.text_layout(@label, @width, @font, @light_label_color),
        dark_idle:  AreaEvents.text_layout(@label, @width, @font, AreaEvents.gray(0.58)),
        light_idle: AreaEvents.text_layout(@label, @width, @font, AreaEvents.gray(0.42)),
      }
      @text_y = @y + (@height - @texts[:dark].extents[1]) / 2
    end

    def draw(ctx : Draw::Context, light : Float64, show_idle : Bool, dark_mode : Bool)
      if show_idle
        outline = AreaEvents.gray(dark_mode ? 0.27 : 0.72)
        ctx.draw_fill(@path, dark_mode ? @gradients[:dark_idle] : @gradients[:light_idle])
        ctx.draw_stroke(@path, AreaEvents.brush(outline), thickness: 1)
        ctx.draw_text_layout(dark_mode ? @texts[:dark_idle] : @texts[:light_idle], @x, @text_y)
      end
      return if light <= 0
      AreaEvents.glow(ctx, @path, @color, light)
      gradient = light == 1.0 ? @gradients[:active] : AreaEvents.vertical_gradient(@x, @y, @height, @active_top, @active_bottom, light)
      ctx.draw_fill(@path, gradient)
      if light == 1.0
        ctx.draw_text_layout(dark_mode ? @texts[:dark] : @texts[:light], @x, @text_y)
      elsif !@label.empty?
        color = dark_mode ? @label_color : @light_label_color
        bright = AreaEvents.text_layout(@label, @width, @font, color, light)
        begin
          ctx.draw_text_layout(bright, @x, @text_y)
        ensure
          bright.free
        end
      end
    end

    def free
      @path.free
      @texts.each { |_name, layout| layout.free }
    end
  end

  class Visualizer
    @keys = [] of Key
    @flashes = {} of String => Time::Instant
    @pressed = Set(String).new
    @held_buttons = 0_u64
    @inside = false
    @dark_mode = true
    @show_idle = true
    @hover_control : Symbol?
    @control_pressed = false
    @pointer : Tuple(Float64, Float64)?
    @trail = [] of PointerSample
    @click_count = 0
    @multi_click : Tuple(Int32, Int32, Time::Instant)?
    @scroll_x : Tuple(Float64, Time::Instant)?
    @scroll_y : Tuple(Float64, Time::Instant)?
    @font = UIng::FontDescriptor.new(size: 12)
    @medium_font = UIng::FontDescriptor.new(size: 10)
    @small_font = UIng::FontDescriptor.new(size: 9)
    @character_font = UIng::FontDescriptor.new(size: 18)
    @mouse_body = AreaEvents.rounded_rectangle(1004.0, 100.0, 108.0, 168.0, 49.0)
    @wheel = AreaEvents.rounded_rectangle(1051.0, 119.0, 14.0, 36.0, 7.0)
    @theme_button = AreaEvents.circle(THEME_X, CONTROL_Y, CONTROL_RADIUS)
    @visibility_button = AreaEvents.circle(VISIBILITY_X, CONTROL_Y, CONTROL_RADIUS)
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
      font = if label.size == 1
               @character_font
             elsif width == 1.0 && label.size >= 5
               @small_font
             elsif width == 1.0 && label.size == 4
               @medium_font
             else
               @font
             end
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
      # Convert shifted punctuation back to the physical keycap label.
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
      @hover_control = control_at(event)
      if event.down == 1 && @hover_control
        @dark_mode = !@dark_mode if @hover_control == :theme
        @show_idle = !@show_idle if @hover_control == :visibility
        @control_pressed = true
        return
      end
      if @control_pressed
        @control_pressed = false if event.up == 1
        return
      end
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
        @multi_click = event.count >= 2 ? {event.count, event.down, now} : nil
      end
    end

    private def control_at(event : UIng::Area::MouseEvent) : Symbol?
      return if event.area_width <= 0 || event.area_height <= 0
      scale, offset_x, offset_y = AreaEvents.viewport(event.area_width, event.area_height)
      return if scale <= 0
      x = (event.x - offset_x) / scale
      y = (event.y - offset_y) / scale
      return if (y - CONTROL_Y).abs > CONTROL_RADIUS
      return :theme if (x - THEME_X)**2 + (y - CONTROL_Y)**2 <= CONTROL_RADIUS**2
      return :visibility if (x - VISIBILITY_X)**2 + (y - CONTROL_Y)**2 <= CONTROL_RADIUS**2
    end

    private def update_pointer(event : UIng::Area::MouseEvent, now : Time::Instant)
      return if event.area_width <= 0 || event.area_height <= 0
      @inside = (0...event.area_width).includes?(event.x) && (0...event.area_height).includes?(event.y)
      position = {
        POINTER_X + POINTER_WIDTH * (event.x / event.area_width).clamp(0.0, 1.0),
        POINTER_Y + POINTER_HEIGHT * (event.y / event.area_height).clamp(0.0, 1.0),
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
      @hover_control = nil if left
      @flashes.delete(left ? "pointer_enter" : "pointer_leave")
      @flashes[left ? "pointer_leave" : "pointer_enter"] = Time.instant
      # Do not join positions on either side of a trip outside the Area.
      @trail.clear unless left
      @pointer = nil unless left
    end

    def scroll_event(event : UIng::Area::ScrollEvent)
      return if event.delta_x == 0 && event.delta_y == 0
      now = Time.instant
      @flashes["wheel_scroll"] = now
      @scroll_x = {event.delta_x, now} if event.delta_x != 0
      @scroll_y = {event.delta_y, now} if event.delta_y != 0
    end

    def drag_broken
      now = Time.instant
      @control_pressed = false
      @held_buttons = 0_u64
      (1..3).each { |button| set_pressed("mouse#{button}", false, now) }
      @trail.clear
      @flashes["broken"] = now
    end

    def focus_lost
      drag_broken unless @held_buttons == 0
      @control_pressed = false
      @hover_control = nil
      now = Time.instant
      @pressed.each { |id| @flashes[id] = now }
      @pressed.clear
      @inside = false
      @pointer = nil
    end

    def tick(area : UIng::Area)
      return if @flashes.empty? && @trail.empty? && !@multi_click && !@scroll_x && !@scroll_y
      now = Time.instant
      @flashes.reject! { |_id, started| now - started >= FADE }
      @trail.reject! { |sample| now - sample.time >= FADE }
      @multi_click = nil if (click = @multi_click) && now - click[2] >= FEEDBACK_FADE
      @scroll_x = nil if (scroll = @scroll_x) && now - scroll[1] >= FEEDBACK_FADE
      @scroll_y = nil if (scroll = @scroll_y) && now - scroll[1] >= FEEDBACK_FADE
      # Also repaint the last frame so every expired glow is erased.
      area.queue_redraw_all
    end

    private def light(id : String, now : Time::Instant) : Float64
      return 1.0 if @pressed.includes?(id)
      return 0.0 unless started = @flashes[id]?
      fade(started, now)
    end

    private def fade(started : Time::Instant, now : Time::Instant, duration = FADE) : Float64
      remaining = (1.0 - (now - started) / duration).clamp(0.0, 1.0)
      remaining * remaining
    end

    def draw(params : UIng::Area::Draw::Params)
      ctx = params.context
      background = AreaEvents.gray(@dark_mode ? 0.018 : 1.0)
      ctx.fill_path(AreaEvents.brush(background)) do |path|
        path.add_rectangle(0, 0, params.area_width, params.area_height)
      end
      return if params.area_width <= 0 || params.area_height <= 0

      scale, offset_x, offset_y = AreaEvents.viewport(params.area_width, params.area_height)
      matrix = Draw::Matrix.new.set_identity
      matrix.translate(offset_x, offset_y)
      matrix.scale(0, 0, scale, scale)
      ctx.save
      begin
        ctx.transform(matrix)
        now = Time.instant
        @keys.each { |key| key.draw(ctx, light(key.id, now), @show_idle, @dark_mode) }
        draw_mouse(ctx, now)
        draw_controls(ctx)
      ensure
        ctx.restore
      end
    end

    private def draw_mouse(ctx : Draw::Context, now : Time::Instant)
      if @show_idle
        fill = AreaEvents.gray(@dark_mode ? 0.07 : 0.93)
        outline = AreaEvents.gray(@dark_mode ? 0.27 : 0.72)
        ctx.draw_fill(@mouse_body, AreaEvents.brush(fill))
        ctx.draw_stroke(@mouse_body, AreaEvents.brush(outline), thickness: 1.2)
        @mouse_buttons.each { |button| ctx.draw_stroke(button, AreaEvents.brush(outline), thickness: 1) }
        ctx.draw_fill(@wheel, AreaEvents.brush(outline, 0.55))
        ctx.draw_stroke(@wheel, AreaEvents.brush(outline), thickness: 1)
      end
      {"pointer_enter" => MINT, "pointer_leave" => GOLD}.each do |id, color|
        pulse = light(id, now)
        if pulse > 0
          ctx.draw_stroke(@mouse_body, AreaEvents.brush(color, 0.07 * pulse), thickness: 10)
          ctx.draw_stroke(@mouse_body, AreaEvents.brush(color, 0.85 * pulse), thickness: 1.5)
        end
      end
      {1, 3}.each_with_index do |button, side|
        AreaEvents.glow(ctx, @mouse_buttons[side], BUTTON_COLORS[button - 1], light("mouse#{button}", now))
      end
      AreaEvents.glow(ctx, @wheel, GOLD, Math.max(light("mouse2", now), light("wheel_scroll", now)))
      draw_scroll_feedback(ctx, now)
      draw_click_feedback(ctx, now)
      draw_pointer(ctx, now)
    end

    private def draw_scroll_feedback(ctx : Draw::Context, now : Time::Instant)
      if scroll = @scroll_x
        delta, started = scroll
        alpha = fade(started, now, FEEDBACK_FADE)
        draw_scroll_arrow(ctx, delta > 0 ? 1084.0 : 1032.0, 137.0, delta > 0 ? :right : :left, CYAN, alpha)
      end
      if scroll = @scroll_y
        delta, started = scroll
        alpha = fade(started, now, FEEDBACK_FADE)
        draw_scroll_arrow(ctx, 1058.0, delta > 0 ? 167.0 : 108.0, delta > 0 ? :down : :up, GOLD, alpha)
      end
    end

    private def draw_scroll_arrow(ctx : Draw::Context, x : Float64, y : Float64,
                                  direction : Symbol, color, alpha : Float64)
      dx, dy = case direction
               when :right then {5.0, 0.0}
               when :left  then {-5.0, 0.0}
               when :down  then {0.0, 5.0}
               else             {0.0, -5.0}
               end
      ctx.stroke_path(AreaEvents.brush(color, alpha), thickness: 2.4, cap: :round) do |path|
        path.new_figure(x - dx - dy, y - dy + dx)
        path.line_to(x, y)
        path.line_to(x - dx + dy, y - dy - dx)
      end
    end

    private def draw_click_feedback(ctx : Draw::Context, now : Time::Instant)
      return unless click = @multi_click
      count, button, started = click
      alpha = fade(started, now, FEEDBACK_FADE)
      x, y, path, color = case button
                          when 1 then {1032.0, 137.0, @mouse_buttons[0], PINK}
                          when 2 then {1058.0, 137.0, @wheel, GOLD}
                          when 3 then {1084.0, 137.0, @mouse_buttons[1], CYAN}
                          else        return
                          end
      ctx.draw_stroke(path, AreaEvents.brush(color, alpha), thickness: 2.5)
      progress = 1.0 - Math.sqrt(alpha)
      count.clamp(2, 3).times do |i|
        radius = 8.0 + i * 8.0 + progress * 18.0
        ctx.stroke_path(AreaEvents.brush(color, alpha * (1.0 - i * 0.18)), thickness: 2.2) do |ring|
          ring.new_figure_with_arc(x, y, radius, 0, 2 * Math::PI, false)
        end
      end
    end

    private def draw_controls(ctx : Draw::Context)
      fill = AreaEvents.gray(@dark_mode ? 0.10 : 1.0)
      hover_fill = AreaEvents.gray(@dark_mode ? 0.18 : 0.91)
      outline = AreaEvents.gray(@dark_mode ? 0.42 : 0.65)
      neutral_color = AreaEvents.gray(@dark_mode ? 0.72 : 0.40)
      theme_color = @dark_mode ? CYAN : LIGHT_SUN
      visibility_color = @dark_mode ? (@show_idle ? MINT : neutral_color) : LIGHT_PIN

      draw_control(ctx, @theme_button, theme_color, fill, hover_fill, outline, @hover_control == :theme)
      draw_control(ctx, @visibility_button, visibility_color, fill, hover_fill, outline, @hover_control == :visibility)

      if @dark_mode
        ctx.fill_path(AreaEvents.brush(theme_color)) do |path|
          path.new_figure_with_arc(THEME_X - 0.5, CONTROL_Y + 0.5, 8.5, 0, 2 * Math::PI, false)
        end
        ctx.fill_path(AreaEvents.brush(@hover_control == :theme ? hover_fill : fill)) do |path|
          path.new_figure_with_arc(THEME_X + 3.5, CONTROL_Y - 2.5, 8, 0, 2 * Math::PI, false)
        end
      else
        ctx.fill_path(AreaEvents.brush(theme_color)) do |path|
          path.new_figure_with_arc(THEME_X, CONTROL_Y, 5.2, 0, 2 * Math::PI, false)
        end
        ctx.stroke_path(AreaEvents.brush(theme_color), thickness: 1.7, cap: :round) do |path|
          8.times do |i|
            angle = i * Math::PI / 4
            path.new_figure(THEME_X + Math.cos(angle) * 8.5, CONTROL_Y + Math.sin(angle) * 8.5)
            path.line_to(THEME_X + Math.cos(angle) * 11.5, CONTROL_Y + Math.sin(angle) * 11.5)
          end
        end
      end

      ctx.fill_path(AreaEvents.brush(visibility_color)) do |path|
        path.new_figure(VISIBILITY_X - 4.5, CONTROL_Y - 8)
        path.line_to(VISIBILITY_X + 4.5, CONTROL_Y - 8)
        path.line_to(VISIBILITY_X + 3.2, CONTROL_Y - 4)
        path.line_to(VISIBILITY_X + 3.2, CONTROL_Y + 1)
        path.line_to(VISIBILITY_X + 6, CONTROL_Y + 3)
        path.line_to(VISIBILITY_X - 6, CONTROL_Y + 3)
        path.line_to(VISIBILITY_X - 3.2, CONTROL_Y + 1)
        path.line_to(VISIBILITY_X - 3.2, CONTROL_Y - 4)
        path.close_figure
      end
      ctx.stroke_path(AreaEvents.brush(visibility_color), thickness: 1.7, cap: :round) do |path|
        path.new_figure(VISIBILITY_X, CONTROL_Y + 3)
        path.line_to(VISIBILITY_X, CONTROL_Y + 10)
      end
      unless @show_idle
        {AreaEvents.brush(@hover_control == :visibility ? hover_fill : fill), AreaEvents.brush(visibility_color)}.each_with_index do |brush, i|
          ctx.stroke_path(brush, thickness: i == 0 ? 4.2 : 1.8, cap: :round) do |path|
            path.new_figure(VISIBILITY_X - 8, CONTROL_Y + 8)
            path.line_to(VISIBILITY_X + 8, CONTROL_Y - 8)
          end
        end
      end
    end

    private def draw_control(ctx : Draw::Context, path : Draw::Path,
                             color, fill, hover_fill, outline, hovered : Bool)
      ctx.draw_fill(path, AreaEvents.brush(hovered ? hover_fill : fill))
      ctx.draw_stroke(path, AreaEvents.brush(hovered ? color : outline), thickness: hovered ? 1.8 : 1.2)
    end

    private def pointer_color(x : Float64, y : Float64)
      AreaEvents.spectrum((x - POINTER_X) / POINTER_WIDTH + (y - POINTER_Y) / POINTER_HEIGHT * 0.2)
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
      {@mouse_body, @wheel, @theme_button, @visibility_button}.each(&.free)
      @mouse_buttons.each(&.free)
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
handler.scroll_event do |area, event|
  visualizer.scroll_event(event)
  area.queue_redraw_all
  true
end

area = UIng::Area.new(handler)
window = UIng::Window.new("Area Events", AreaEvents::WIDTH.to_i, AreaEvents::HEIGHT.to_i)
# GTK may allocate a directly attached Area at its 1px natural width.
box = UIng::Box.new(:vertical)
box.append(area, stretchy: true)
window.child = box
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
