# ColorButton

[日本語](../guide_ja/widget-color-button.html)

ColorButton opens the platform color chooser and stores an RGBA color.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_color_button-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_color_button-ubuntu.png" alt="ColorButton on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_color_button-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_color_button-windows.png" alt="ColorButton on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_color_button-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_color_button-macos.png" alt="ColorButton on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_color_button" %}}

## Usage notes

- RGBA components are floating-point values from <code>0.0</code> through <code>1.0</code>.
- <code>on_changed</code> receives red, green, blue, and alpha values.

[API reference](../../api/UIng/ColorButton.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_color_button.cr)
