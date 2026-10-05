---
title: "UIng Guide"
---

## Native desktop apps in Crystal

UIng is a Crystal binding for libui-ng. Build small, cross-platform
interfaces with the native controls of Linux, macOS, and Windows.

[English Guide →](books/guide_en/) ·
[日本語ガイド →](books/guide_ja/) ·
[API reference →](api/) ·
[View on GitHub →](https://github.com/kojix2/uing)

## One API, native controls

UIng uses the platform's native GUI toolkit: GTK on Linux, AppKit on macOS,
and Win32 on Windows. Use the regular object-oriented API or the optional
block-based DSL; both create the same controls.

<pre><code class="crystal">
require "uing"

UIng.init

window = UIng::Window.new("Hello World", 300, 200)
window.on_closing do
  UIng.quit
  true
end

window.child = UIng::Label.new("Hello from UIng")
window.show

UIng.main
UIng.uninit
</code></pre>

[日本語で読む →](books/guide_ja/) ·
[Read in English →](books/guide_en/) ·
[Browse the API reference →](api/)
