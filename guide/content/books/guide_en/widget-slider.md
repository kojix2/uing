# Slider

[日本語](../guide_ja/widget-slider.html)

Slider selects an integer within a bounded range.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_slider-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_slider-ubuntu.png" alt="Slider on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_slider-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_slider-windows.png" alt="Slider on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_slider-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_slider-macos.png" alt="Slider on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_slider" %}}

## Usage notes

- Use <code>on_changed</code> for live updates and <code>on_released</code> after dragging ends.
- <code>has_tool_tip</code> controls the native value tooltip.

[API reference](../../api/UIng/Slider.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_slider.cr)
