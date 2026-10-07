# First Steps

[日本語](../guide_ja/first-steps.html)

This application opens a native window containing a button. Clicking the
button displays a message box.

This is the regular object-oriented API used throughout most of the guide.
The equivalent block-based form is described in
[Coding Styles](coding-styles.md).

<pre><code class="crystal">
require "uing"

UIng.init

window = UIng::Window.new("Hello World", 300, 200)
window.on_closing do
  UIng.quit
  true
end

button = UIng::Button.new("Click me")
button.on_clicked do
  window.msg_box("UIng", "Hello from Crystal!")
end

window.child = button
window.show

UIng.main
UIng.uninit
</code></pre>

Save the source as `hello.cr`, then run it:

<pre><code class="bash">
crystal run hello.cr
</code></pre>

## How it works

1. `UIng.init` initializes the native GUI backend.
2. `Window.new` and `Button.new` create native controls.
3. `on_clicked` registers code to run after a click.
4. Assigning `window.child` places the button in the window.
5. `window.show` displays the interface.
6. `UIng.main` runs the event loop until the closing callback calls
   `UIng.quit`.
7. `UIng.uninit` releases application-wide resources after the loop ends.

Returning `true` from `on_closing` allows the window to close. `UIng.init`
also accepts a block; in that case `UIng.uninit` is called automatically
after the event loop returns. See
[Runtime and Lifetime](runtime-and-lifetime.md) for details.
