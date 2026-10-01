---
title: "UIng Guide"
---

## Native desktop apps in Crystal

UIng is a Crystal binding for libui-ng. Build small, cross-platform
interfaces with the native controls of Linux, macOS, and Windows.

[Get started →](books/guide/first-steps.html) ·
[API reference →](api/) ·
[View on GitHub →](https://github.com/kojix2/uing)

## One API, native controls

UIng uses the platform's native GUI toolkit: GTK on Linux, AppKit on macOS,
and Win32 on Windows. Use the regular object-oriented API or the optional
block-based DSL; both create the same controls.

<pre><code class="crystal">
require "uing"

UIng.init do
  UIng::Window.new("Hello World", 300, 200) {
    on_closing { UIng.quit; true }
    child { UIng::Label.new("Hello from UIng") }
    show
  }

  UIng.main
end
</code></pre>

[Read the guide →](books/guide/) · [Browse the API reference →](api/)
