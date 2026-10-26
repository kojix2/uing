# Area input and redraws

[日本語](../guide_ja/area-input-and-redraw.html)

A drawing callback displays state. Change state in input callbacks or timers, then call `queue_redraw_all` to schedule the next draw. `queue_redraw_all` does not draw immediately.

```crystal
x = 80.0
y = 80.0
brush = UIng::Area::Draw::Brush.new(:solid, 0.2, 0.4, 0.8, 1.0)

handler = UIng::Area::Handler.new do
  draw do |_area, params|
    params.context.fill_path(brush) do |path|
      path.add_rectangle(x, y, 24, 24)
    end
  end

  mouse_event do |area, event|
    x = event.x
    y = event.y
    area.queue_redraw_all
  end

  key_event do |area, event|
    handled = !event.up? && event.ext_key == UIng::Area::ExtKey::Left
    x -= 8 if handled
    area.queue_redraw_all if handled
    handled
  end

  scroll_event do |area, event|
    puts "Scroll: #{event.delta_x}, #{event.delta_y}"
    true # Consume the event; return false for normal scrolling in a scrolling Area.
  end
end

area = UIng::Area.new(handler)
```

## Input callbacks

- `mouse_event` receives coordinates, button state, and modifiers.
- `mouse_crossed` receives pointer enter/leave changes.
- `drag_broken` can restore state when a drag is interrupted.
- `key_event` returns `true` when it handled the key and `false` otherwise.
- `scroll_event` receives wheel and trackpad movement in `delta_x` and `delta_y`; call `handler.scroll_event(nil)` to clear it.

Scroll deltas are signed device amounts, not drawing coordinates. Their size varies by device and platform. Positive values mean right and down.

Call `area.focus` to request keyboard focus after attaching it to a visible window. Check `area.focused?` if needed; the native window system may reject the request.

Call `begin_user_window_move` and `begin_user_window_resize` only inside `mouse_event` while `event.down != 0`. For animation, avoid creating drawing resources every frame and redraw only after state changes.

[area_events.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/area_events.cr) visualizes keyboard and mouse input. [area_analog_clock.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/area_analog_clock.cr) and [reversi.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/reversi.cr) combine state with redraws.
