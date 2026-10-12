# FontButton

[日本語](../guide_ja/widget-font-button.html)

FontButton opens the native font chooser and reports a FontDescriptor.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_font_button-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_font_button-ubuntu.png" alt="FontButton on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_font_button-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_font_button-windows.png" alt="FontButton on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_font_button-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_font_button-macos.png" alt="FontButton on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_font_button" %}}

## Usage notes

- <code>font</code> returns the currently selected <code>FontDescriptor</code>.
- Handle a new choice with <code>on_changed</code>. Its descriptor can be
  retained after the callback.
- The block-based <code>font</code> form is also available. None of these
  descriptors needs <code>free</code>.

[API reference](../../api/UIng/FontButton.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_font_button.cr)
