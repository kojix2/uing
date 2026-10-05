# Coding Styles

[日本語](../guide_ja/coding-styles.html)

UIng offers two equivalent ways to construct an interface. Both styles use
the same controls and may be mixed in one application.

## Regular API

The regular API is explicit and familiar. This guide mostly uses this form.

<pre><code class="crystal">
window = UIng::Window.new("Hello", 300, 200)
window.child = UIng::Label.new("Hello from UIng")
</code></pre>

## Block-based DSL

The block-based DSL keeps nested layouts visually close to their resulting
control hierarchy:

<pre><code class="crystal">
UIng::Window.new("Hello", 300, 200) {
  child { UIng::Label.new("Hello from UIng") }
}
</code></pre>

Here is an example with a deeper nesting:

<pre><code class="crystal">
UIng.init do
  UIng::Window.new("Hello World", 300, 200) { |win|
    on_closing { UIng.quit; true }
    child {
      UIng::Button.new("Click me") {
        on_clicked {
          win.msg_box("Info", "Button clicked!")
        }
      }
    }
    show
  }

  UIng.main
end
</code></pre>

The DSL is implemented with Crystal's `with ... yield` syntax. Inside a
block, methods are called with the control instance as `self`, so instead of
assignments like `window.child = ...` you can write `child { ... }`.

## Which to choose

- Regular API: suits simple structures and code where you want the flow to
  be explicit.
- DSL: suits deeply nested layouts that read best when written close to
  their hierarchy.

Both styles create the same controls. Either choice is fine as long as the
project stays consistent.
