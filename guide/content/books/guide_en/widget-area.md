# Area

[日本語](../guide_ja/widget-area.html)

Area is a custom drawing surface driven by an Area::Handler.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_basic_shapes-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_basic_shapes-ubuntu.png" alt="Area on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_basic_shapes-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_basic_shapes-windows.png" alt="Area on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_basic_shapes-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_basic_shapes-macos.png" alt="Area on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example area_basic_shapes" %}}

## Basic setup

Create an `Area::Handler`, register a `draw` callback, then pass the handler to `Area.new`. The handler is retained by the Area for as long as the Area exists.

```crystal
handler = UIng::Area::Handler.new do
  draw do |_area, params|
    brush = UIng::Area::Draw::Brush.new(:solid, 0.2, 0.4, 0.8, 1.0)
    params.context.fill_path(brush) do |path|
      path.add_rectangle(30, 30, 120, 70)
    end
  end
end

area = UIng::Area.new(handler)
window.child = area
```

Initialize UIng before creating controls, show the window, and run `UIng.main` as in the runnable example. The `Area.new(handler, width, height)` overload creates a scrolling area; the dimensions specify its content size.

## In this chapter

This page introduces Area creation and the first drawing callback. Grow a drawing program through the following focused pages.

- [Paths, brushes, and strokes](area-paths-and-brushes.html): shapes, fills, strokes, and clipping
- [Text, images, and transforms](area-text-images-and-transforms.html): text layout, images, and Matrix
- [Input and redraws](area-input-and-redraw.html): mouse/keyboard input, state, and animation
- [Scrolling and examples](area-scrolling-and-examples.html): scrolling Areas, visible regions, and next examples

## Related examples

<div class="widget-screenshots">
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_colors_and_brushes.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_colors_and_brushes-ubuntu.png" alt="Colors and brushes" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_colors_and_brushes.cr">Colors and brushes</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_analog_clock.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_analog_clock-ubuntu.png" alt="Analog clock" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_analog_clock.cr">Analog clock</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_matrix.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_matrix-ubuntu.png" alt="Matrix transforms" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_matrix.cr">Matrix transforms</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/basic_draw_text.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_draw_text-ubuntu.png" alt="Text drawing" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/basic_draw_text.cr">Text drawing</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/reversi.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/reversi-ubuntu.png" alt="Reversi" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/reversi.cr">Reversi</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_breakout.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_breakout-ubuntu.png" alt="Breakout" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_breakout.cr">Breakout</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/boid3d.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/boid3d-ubuntu.png" alt="Boid 3D" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/boid3d.cr">Boid 3D</a></figcaption></figure>
</div>

The optional CrImage integration has a separate
[image drawing example](https://github.com/kojix2/uing/blob/main/examples/crimage/area_draw_image.cr).

[API reference](../../api/UIng/Area.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/area_basic_shapes.cr)
