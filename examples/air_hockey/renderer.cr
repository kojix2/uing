class AirHockey3DRenderer
  def initialize(@game : AirHockey3DGame)
  end

  # Draw back-to-front. Far objects are drawn first, then the puck/player mallet
  # on top so overlaps read naturally in the faux-3D view.
  def draw(params)
    @game.screen_width = params.area_width
    @game.screen_height = params.area_height
    ctx = params.context

    draw_background(ctx)
    draw_table(ctx)
    draw_score(ctx)
    draw_disc(ctx, @game.opponent.position, @game.opponent.radius, {r: 0.95, g: 0.32, b: 0.24}, 26.0)
    draw_puck(ctx)
    draw_disc(ctx, @game.player.position, @game.player.radius, {r: 0.18, g: 0.56, b: 0.95}, 26.0)
    draw_message(ctx)
  end

  private def brush(r, g, b, a = 1.0)
    UIng::Area::Draw::Brush.new(:solid, r, g, b, a)
  end

  private def ellipse(path, cx : Float64, cy : Float64, rx : Float64, ry : Float64)
    kappa = 0.5522847498307936
    ox = rx * kappa
    oy = ry * kappa

    path.new_figure(cx + rx, cy)
    path.bezier_to(cx + rx, cy + oy, cx + ox, cy + ry, cx, cy + ry)
    path.bezier_to(cx - ox, cy + ry, cx - rx, cy + oy, cx - rx, cy)
    path.bezier_to(cx - rx, cy - oy, cx - ox, cy - ry, cx, cy - ry)
    path.bezier_to(cx + ox, cy - ry, cx + rx, cy - oy, cx + rx, cy)
    path.close_figure
  end

  # Keep the background intentionally simple. The table and pieces carry the
  # visual design, and solid fills are the most portable across libui backends.
  private def draw_background(ctx)
    ctx.fill_path(brush(0.035, 0.043, 0.055)) do |path|
      path.add_rectangle(0.0, 0.0, @game.screen_width, @game.screen_height)
    end
  end

  private def draw_table(ctx)
    outline = table_outline_points

    ctx.fill_path(brush(0.58, 0.62, 0.66, 0.20)) do |path|
      path.new_figure(outline.first[:x] + 4.0, outline.first[:y] + 20.0)
      outline[1..].each { |point| path.line_to(point[:x] + 4.0, point[:y] + 20.0) }
      path.close_figure
    end

    ctx.fill_path(brush(0.10, 0.31, 0.40)) do |path|
      path.new_figure(outline.first[:x], outline.first[:y])
      outline[1..].each { |point| path.line_to(point[:x], point[:y]) }
      path.close_figure
    end

    draw_table_lines(ctx)
    draw_goals(ctx)
  end

  private def table_outline_points
    half_w = @game.table_width / 2.0
    half_d = @game.table_depth / 2.0
    radius = [AirHockey3DConfig::CORNER_R, half_w, half_d].min
    points = [] of NamedTuple(x: Float64, y: Float64, scale: Float64)

    add_corner_points(points, half_w - radius, -half_d + radius, -90.0, 0.0, radius)
    add_corner_points(points, half_w - radius, half_d - radius, 0.0, 90.0, radius)
    add_corner_points(points, -half_w + radius, half_d - radius, 90.0, 180.0, radius)
    add_corner_points(points, -half_w + radius, -half_d + radius, 180.0, 270.0, radius)
    points
  end

  private def add_corner_points(points, cx : Float64, cz : Float64, from_degrees : Float64, to_degrees : Float64, radius : Float64)
    steps = 8
    steps.times do |index|
      t = index / steps
      angle = (from_degrees + (to_degrees - from_degrees) * t) * Math::PI / 180.0
      points << @game.project(Vec2.new(cx + Math.cos(angle) * radius, cz + Math.sin(angle) * radius))
    end
  end

  private def draw_table_lines(ctx)
    line_brush = brush(0.84, 0.93, 0.95, 0.72)
    edge_brush = brush(0.78, 0.86, 0.88, 0.9)
    outline = table_outline_points
    center_left = @game.project(Vec2.new(-@game.table_width / 2.0, 0.0))
    center_right = @game.project(Vec2.new(@game.table_width / 2.0, 0.0))

    ctx.stroke_path(edge_brush, thickness: 5.0) do |path|
      path.new_figure(outline.first[:x], outline.first[:y])
      outline[1..].each { |point| path.line_to(point[:x], point[:y]) }
      path.close_figure
    end

    ctx.stroke_path(line_brush, thickness: 2.0) do |path|
      path.new_figure(center_left[:x], center_left[:y])
      path.line_to(center_right[:x], center_right[:y])
    end

    center = @game.project(Vec2.new(0.0, 0.0))
    ctx.stroke_path(line_brush, thickness: 2.0) do |path|
      r = 78.0 * center[:scale]
      ellipse(path, center[:x], center[:y], r, r * 0.42)
    end
  end

  private def draw_goals(ctx)
    [-1.0, 1.0].each do |side|
      z = side * @game.table_depth / 2.0
      left = @game.project(Vec2.new(-@game.goal_width / 2.0, z))
      right = @game.project(Vec2.new(@game.goal_width / 2.0, z))
      y_offset = side < 0 ? 15.0 : -15.0

      ctx.stroke_path(brush(0.02, 0.025, 0.03, 0.42), thickness: 10.0) do |path|
        path.new_figure(left[:x], left[:y] + y_offset)
        path.line_to(right[:x], right[:y] + y_offset)
      end

      ctx.stroke_path(brush(1.0, 0.74, 0.24, 0.96), thickness: 5.0) do |path|
        path.new_figure(left[:x], left[:y] + y_offset)
        path.line_to(right[:x], right[:y] + y_offset)
      end
    end
  end

  private def draw_disc(ctx, position : Vec2, radius : Float64, rgb, height : Float64)
    projected = @game.project(position)
    r = radius * projected[:scale]
    h = height * projected[:scale]
    y_ratio = 0.72

    ctx.fill_path(brush(0.0, 0.0, 0.0, 0.24)) do |path|
      ellipse(path, projected[:x] + r * 0.18, projected[:y] + h + r * 0.22, r * 0.92, r * 0.92 * 0.52)
    end

    ctx.fill_path(brush(rgb[:r] * 0.46, rgb[:g] * 0.46, rgb[:b] * 0.46, 1.0)) do |path|
      ellipse(path, projected[:x], projected[:y] + h * 0.45, r, r * y_ratio)
    end

    ctx.fill_path(brush(rgb[:r], rgb[:g], rgb[:b], 1.0)) do |path|
      ellipse(path, projected[:x], projected[:y], r, r * y_ratio)
    end

    ctx.fill_path(brush(1.0, 1.0, 1.0, 0.26)) do |path|
      ellipse(path, projected[:x] - r * 0.28, projected[:y] - r * 0.20, r * 0.34, r * 0.22)
    end
  end

  private def draw_puck(ctx)
    projected = @game.project(@game.puck.position)
    r = @game.puck.radius * projected[:scale]
    h = 5.0 * projected[:scale]
    y_ratio = 0.62

    # The puck is flatter than the mallets; smaller shadow/sidewall keeps it readable.
    ctx.fill_path(brush(0.0, 0.0, 0.0, 0.20)) do |path|
      ellipse(path, projected[:x] + r * 0.20, projected[:y] + h + r * 0.16, r * 0.78, r * 0.38)
    end

    ctx.fill_path(brush(0.62, 0.68, 0.70, 1.0)) do |path|
      ellipse(path, projected[:x], projected[:y] + h * 0.55, r * 0.86, r * 0.86 * y_ratio)
    end

    ctx.fill_path(brush(0.92, 0.96, 0.95, 1.0)) do |path|
      ellipse(path, projected[:x], projected[:y], r * 0.86, r * 0.86 * y_ratio)
    end

    ctx.stroke_path(brush(0.42, 0.50, 0.52, 0.85), thickness: 1.5) do |path|
      ellipse(path, projected[:x], projected[:y], r * 0.86, r * 0.86 * y_ratio)
    end

    ctx.fill_path(brush(1.0, 1.0, 1.0, 0.58)) do |path|
      ellipse(path, projected[:x] - r * 0.24, projected[:y] - r * 0.18, r * 0.24, r * 0.14)
    end
  end

  private def draw_score(ctx)
    score_y = 10.0
    draw_text(ctx, "#{@game.opponent_score}", @game.screen_width / 2.0 - 86.0, score_y, 34.0, 70.0, 0.98, 0.34, 0.28, UIng::Area::Draw::TextAlign::Center)
    draw_text(ctx, "#{@game.player_score}", @game.screen_width / 2.0 + 16.0, score_y, 34.0, 70.0, 0.30, 0.66, 1.0, UIng::Area::Draw::TextAlign::Center)
  end

  private def draw_message(ctx)
    return if @game.message.empty?
    draw_text(ctx, @game.message, 0.0, @game.screen_height * 0.46, 24.0, @game.screen_width, 1.0, 1.0, 1.0, UIng::Area::Draw::TextAlign::Center)
    draw_text(ctx, "Mouse to move  |  WASD / arrows to nudge", 0.0, @game.screen_height * 0.46 + 36.0, 14.0, @game.screen_width, 0.76, 0.84, 0.88, UIng::Area::Draw::TextAlign::Center)
  end

  private def draw_text(ctx, text : String, x : Float64, y : Float64, size : Float64, width : Float64, r : Float64, g : Float64, b : Float64, align)
    return if text.empty?

    font = UIng::FontDescriptor.new(
      family: "Arial",
      size: size.to_i,
      weight: UIng::TextWeight::Bold,
      italic: UIng::TextItalic::Normal,
      stretch: UIng::TextStretch::Normal
    )
    string = UIng::Area::AttributedString.new(text)
    begin
      string.set_attribute(UIng::Area::Attribute.new_color(r, g, b, 1.0), 0, string.len)
      UIng::Area::Draw::TextLayout.open(
        string: string,
        default_font: font,
        width: [width, 1.0].max,
        align: align
      ) do |layout|
        ctx.draw_text_layout(layout, x, y)
      end
    ensure
      string.free
    end
  end
end
