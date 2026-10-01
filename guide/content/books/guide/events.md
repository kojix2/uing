# Events

UIng applications respond to native events with callback blocks. Register
callbacks while building the interface, before calling `UIng.main`.

<pre><code class="crystal">
entry = UIng::Entry.new
button = UIng::Button.new("Greet")

button.on_clicked do
  name = entry.text || ""
  window.msg_box("Greeting", "Hello, #{name}!")
end
</code></pre>

Callbacks expose values when useful. For example, `Entry#on_changed` yields
the current text and `Slider#on_changed` yields the current integer value.

<pre><code class="crystal">
entry.on_changed do |text|
  status.text = "#{text.size} characters"
end
</code></pre>

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
