# Area paths, brushes, and strokes

[日本語](../guide_ja/area-paths-and-brushes.html)

Draw with `params.context` inside `draw`. A Context is valid only for that callback.

## Fills and strokes

`fill_path` and `stroke_path` end and free their paths. Use them for normal drawing.

```crystal
handler = UIng::Area::Handler.new do
  draw do |_area, params|
    fill = UIng::Area::Draw::Brush.new(:solid, 0.2, 0.4, 0.8, 1.0)
    params.context.fill_path(fill) { |path| path.add_rectangle(24, 24, 160, 80) }

    line = UIng::Area::Draw::Brush.new(:solid, 0.1, 0.1, 0.1, 1.0)
    params.context.stroke_path(line, thickness: 2.0) do |path|
      path.new_figure(24, 128).line_to(184, 184)
    end
  end
end
```

Use `draw_path` to fill and stroke one path. Supply `fill_brush`, `stroke_brush`, and `stroke_params` as needed.

## Brushes

`Brush.new` accepts `:solid`, `:linear_gradient`, and `:radial_gradient`. The `r`, `g`, `b`, and `a` components range from 0.0 to 1.0; `a` is opacity.

| Type | Values |
| --- | --- |
| Solid | `:solid, r, g, b, a` |
| Linear gradient | `:linear_gradient, x0:, y0:, x1:, y1:, stops:` |
| Radial gradient | `:radial_gradient, x0:, y0:, x1:, y1:, outer_radius:, stops:` |

A linear gradient runs from `x0, y0` to `x1, y1`. A radial gradient uses `x0, y0` for its inner circle and `x1, y1` plus `outer_radius` for its outer circle.

```crystal
stops = [
  UIng::Area::Draw::Brush::GradientStop.new(0.0, 1.0, 0.8, 0.0, 1.0),
  UIng::Area::Draw::Brush::GradientStop.new(1.0, 1.0, 0.1, 0.0, 1.0),
]

linear = UIng::Area::Draw::Brush.new(
  :linear_gradient, x0: 24, y0: 24, x1: 184, y1: 24, stops: stops
)
radial = UIng::Area::Draw::Brush.new(
  :radial_gradient, x0: 100, y0: 100, x1: 100, y1: 100,
  outer_radius: 60, stops: stops
)
```

`GradientStop` positions and color components also range from 0.0 to 1.0; list stops in position order. With `require "uing/crimage"`, `Brush.solid(color)` and `GradientStop.new(position, color)` accept CrImage colors.

## Paths

Start a figure with `new_figure` or `new_figure_with_arc`. `add_rectangle` adds a rectangle. Use `close_figure` for a closed outline.

| Shape | Method |
| --- | --- |
| Rectangle | `add_rectangle(x, y, width, height)` |
| Line | `new_figure(x, y)` → `line_to(x, y)` |
| Cubic Bézier curve | `bezier_to(c1x, c1y, c2x, c2y, end_x, end_y)` |
| Start with an arc | `new_figure_with_arc(x, y, radius, start_angle, sweep, negative)` |
| Add an arc | `arc_to(x, y, radius, start_angle, sweep, negative)` |

Angles are radians. `start_angle` is the start, `sweep` is the angle to draw, and `negative` selects direction.

```crystal
params.context.fill_path(brush) do |path|
  path.new_figure(80, 20).line_to(140, 120).line_to(20, 120).close_figure # triangle
  path.new_figure_with_arc(220, 70, 40, 0, Math::PI * 2, false)             # circle
end

params.context.stroke_path(brush, thickness: 2.0) do |path|
  path.new_figure(20, 100)
  path.bezier_to(70, 20, 130, 180, 180, 100)
end

params.context.fill_path(brush) do |path| # sector
  path.new_figure(100, 100)
  path.arc_to(100, 100, 60, 0, Math::PI / 2, false)
  path.close_figure
end
```

## Strokes, fill rules, and clipping

`StrokeParams` accepts `thickness`, `cap` (`:flat`, `:round`, `:square`), `join` (`:miter`, `:round`, `:bevel`), `miter_limit`, `dashes`, and `dash_phase`.

```crystal
dashed = UIng::Area::Draw::StrokeParams.new(
  thickness: 4.0, cap: :round, join: :round, dashes: [8.0, 4.0]
)
```

For self-intersections and holes, pass `mode: :winding` (the default) or `:alternate` to `fill_path` or `draw_path`. Restrict drawing with `clip_path`, enclosed by `save` and `restore`.

```crystal
context.save
context.clip_path { |path| path.add_rectangle(0, 0, 120, 80) }
# Draw only in this rectangle.
context.restore
```

When using `Path.open`, call `end_path` before drawing; the path is freed at the end of the block. `params.clip_x`, `clip_y`, `clip_width`, and `clip_height` identify the region that needs repainting.

See [area_basic_shapes.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/area_basic_shapes.cr) and [area_colors_and_brushes.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/area_colors_and_brushes.cr).
