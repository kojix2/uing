# Window

[日本語](../guide_ja/widget-window.html)

Window is the top-level container for an application. It owns one child control, so use a layout container when the interface has multiple controls.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-ubuntu.png" alt="Window on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-windows.png" alt="Window on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-macos.png" alt="Window on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_window" %}}

## Usage notes

- Register <code>on_closing</code> and call <code>UIng.quit</code> to end the event loop.
- Use <code>margined</code>, <code>content_size</code>, <code>fullscreen</code>, and <code>borderless</code> to control the native window.

[API reference](../../api/UIng/Window.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_window.cr)
