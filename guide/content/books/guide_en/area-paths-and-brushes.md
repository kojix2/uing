# Area paths, brushes, and strokes

[日本語](../guide_ja/area-paths-and-brushes.html)

In a `draw` callback, use `params.context` to fill or stroke paths. The Context is valid only while that callback runs.

## Fills and strokes

The block forms of `fill_path` and `stroke_path` end and free their paths. They are the safest way to begin.

```crystal
handler = UIng::Area::Handler.new do
  draw do |_area, params|
    blue = UIng::Area::Draw::Brush.new(:solid, 0.2, 0.4, 0.8, 1.0)
    params.context.fill_path(blue) do |path|
      path.add_rectangle(24, 24, 160, 80)
    end

    outline = UIng::Area::Draw::Brush.new(:solid, 0.1, 0.1, 0.1, 1.0)
    stroke = UIng::Area::Draw::StrokeParams.new(thickness: 2.0)
    params.context.stroke_path(outline, stroke) do |path|
      path.new_figure(24, 128)
      path.line_to(184, 184)
    end
  end
end

area = UIng::Area.new(handler)
```

The `r`, `g`, `b`, and `a` color components range from 0.0 to 1.0. A `Brush` can be solid, linear-gradient, or radial-gradient. `StrokeParams` controls thickness, caps, joins, and dash patterns.

## Paths and visible regions

Paths can contain rectangles, lines, Bézier curves, and arcs. If you use `Path.open` directly, call `end_path` before drawing and free the path when it is no longer needed. Reusing a static Path can reduce work for frequently drawn shapes.

`params.clip_x`, `clip_y`, `clip_width`, and `clip_height` identify the region that needs painting. On a large canvas, skip objects outside that region.

[area_colors_and_brushes.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/area_colors_and_brushes.cr) demonstrates solid colors, transparency, and gradients.
