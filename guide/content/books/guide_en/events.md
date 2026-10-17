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

Keep referenced controls and application data alive for as long as a callback
may use them. Callback exceptions are logged by UIng instead of crossing the
native callback boundary.
