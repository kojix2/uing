# Events

[日本語](../guide_ja/events.html)

UIng applications respond to native events with callback blocks. Register
callbacks while building the interface, before calling `UIng.main`. This
excerpt uses the `window` created in [First Steps](first-steps.html).

<pre><code class="crystal">
entry = UIng::Entry.new
button = UIng::Button.new("Greet")
status = UIng::Label.new("Enter your name")

button.on_clicked do
  name = entry.text || ""
  window.msg_box("Greeting", "Hello, #{name}!")
end

entry.on_changed do |text|
  status.text = "#{text.size} characters"
end
</code></pre>

Callbacks expose values when useful. For example, `Entry#on_changed` yields
the current text and `Slider#on_changed` yields the current integer value.

## Clearing callbacks

Each `on_*` registration has a matching `clear_on_*` method. For example,
`button.clear_on_clicked` is the same as `button.on_clicked(nil)`, and
`entry.clear_on_changed` is the same as `entry.on_changed(nil)`. Clearing a
callback releases its Crystal closure and leaves the control available for a
later registration. The same convention applies to MenuItem, ToolbarItem,
Table, Window, and `UIng.clear_on_should_quit`. `Area::Handler` uses
`clear_draw`, `clear_mouse_event`, and similar names; these are equivalent to
passing `nil` to the corresponding registration method.
`MultilineEntry#clear_on_changed` and `#clear_on_changed_with_text` both clear
the same change callback slot. `Table::Model::Handler#clear_set_cell_value` is
equivalent to `set_cell_value(nil)` for the optional edit callback.
`UIng.clear_on_error` is equivalent to `UIng.on_error(nil)`.

Native callbacks remain installed as harmless defaults where libui-ng requires
a non-null callback. After `window.clear_on_closing`, a close request is
rejected, matching a newly created Window without a closing handler. After
`UIng.clear_on_should_quit`, an application-wide quit request is rejected.
Register a new handler when the application should respond to either request.

## Updating the interface

Native controls should be read and changed on the UI thread. If work performed
elsewhere needs to update the interface, schedule only the UI update with
`UIng.queue_main`:

<pre><code class="crystal">
UIng.queue_main do
  status.text = "Finished"
end
</code></pre>

## Timers

`UIng.timer` accepts a `Time::Span` or an integer number of milliseconds and
runs its block on the UI thread. Both overloads return the same timer handle.
Return `true` to repeat or `false` to stop. The returned timer can also be
stopped from another UI callback:

<pre><code class="crystal">
clock = UIng.timer(250.milliseconds) do
  status.text = Time.local.to_s
  true
end

button.on_clicked { clock.stop }
</code></pre>

`clock.stopped?` becomes true as soon as it is stopped. `stop` prevents further
user callbacks, while libui-ng removes its native timer at the next tick.
Call `UIng.timer` after `UIng.init` and before `UIng.uninit`. `Time::Span`
intervals shorter than one millisecond are rounded up. Integer intervals must
be between 1 and `Int32::MAX` milliseconds.

For code written against the former integer-millisecond API, keep the interval
and change the block result: `UIng.timer(250) { true }` repeats, while
`UIng.timer(250) { false }` stops. The old results `1` and `0` no longer compile.

Closures retain captured Crystal objects. Keep their native resources unfreed while
callbacks use them. UIng logs callback exceptions without unwinding into C.
