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

## Drawing

- `draw` runs when painting is needed. `params.area_width` and `params.area_height` are defined only for non-scrolling Areas. Track scrolling Area content sizes in your application. `clip_x`, `clip_y`, `clip_width`, and `clip_height` describe the portion being drawn.
- Use `params.context.fill_path` or `stroke_path` to end and free paths automatically. When using `Path.open` directly, call `end_path` before drawing. Brush color components (`r`, `g`, `b`, `a`) range from 0.0 to 1.0.
- The drawing context is valid only during `draw`. Do not store it or use it after the callback returns.

## Usage notes

- Handle input by registering `mouse_event`, `mouse_crossed`, `drag_broken`, or `key_event` on the same handler. Mouse coordinates are available on the event; `key_event` should return `true` when the key was handled and `false` otherwise.
- Keep application state outside the draw callback. Update that state in input callbacks or a timer, then call `area.queue_redraw_all` to request a new frame. This schedules drawing; it does not draw immediately.
- `set_size` and `scroll_to` are for scrolling Areas only. Call `begin_user_window_move` or `begin_user_window_resize` only inside `mouse_event` when `event.down != 0`.

## Related examples

<div class="widget-screenshots">
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_colors_and_brushes.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_colors_and_brushes-ubuntu.png" alt="Colors and brushes" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_colors_and_brushes.cr">Colors and brushes</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_analog_clock.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_analog_clock-ubuntu.png" alt="Analog clock" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_analog_clock.cr">Analog clock</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_matrix.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_matrix-ubuntu.png" alt="Matrix transforms" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_matrix.cr">Matrix transforms</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/basic_draw_text.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_draw_text-ubuntu.png" alt="Text drawing" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/basic_draw_text.cr">Text drawing</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/reversi.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/reversi-ubuntu.png" alt="Reversi" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/reversi.cr">Reversi</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_breakout.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_breakout-ubuntu.png" alt="Breakout" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_breakout.cr">Breakout</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/boid3d.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/boid3d-ubuntu.png" alt="Boid 3D" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/boid3d.cr">Boid 3D</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_draw_image.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_draw_image-ubuntu.png" alt="Image drawing" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_draw_image.cr">Image drawing</a></figcaption></figure>
</div>

[API reference](../../api/UIng/Area.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/area_basic_shapes.cr)
