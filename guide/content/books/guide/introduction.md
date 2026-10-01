# Introduction

UIng is a Crystal binding for
[libui-ng](https://github.com/kojix2/libui-ng), a portable library for native
desktop interfaces. It gives Crystal applications access to windows, buttons,
text fields, menus, tables, drawing areas, and other standard controls without
shipping a browser engine or a custom widget toolkit.

The same application source can target:

- Linux and other Unix-like systems through GTK 3
- macOS through AppKit
- Windows through Win32, Direct2D, and DirectWrite

UIng offers two equivalent ways to construct an interface. The regular API is
explicit and familiar:

<pre><code class="crystal">
window = UIng::Window.new("Hello", 300, 200)
window.child = UIng::Label.new("Hello from UIng")
</code></pre>

The block-based DSL keeps nested layouts visually close to their resulting
control hierarchy:

<pre><code class="crystal">
UIng::Window.new("Hello", 300, 200) {
  child { UIng::Label.new("Hello from UIng") }
}
</code></pre>

Both styles use the same controls and may be mixed in one application.

This guide focuses on the small set of concepts needed to create an
application. For the complete list of types and methods, use the
[API Reference](../../api/).
