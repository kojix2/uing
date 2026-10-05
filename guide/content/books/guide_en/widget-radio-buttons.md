# RadioButtons

[日本語](../guide_ja/widget-radio-buttons.html)

RadioButtons presents a group in which at most one option is selected.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_radio_buttons-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_radio_buttons-ubuntu.png" alt="RadioButtons on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_radio_buttons-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_radio_buttons-windows.png" alt="RadioButtons on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_radio_buttons-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_radio_buttons-macos.png" alt="RadioButtons on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_radio_buttons" %}}

## Usage notes

- Selection uses a zero-based index and may be <code>nil</code>.
- <code>on_selected</code> receives the selected index.

[API reference](../../api/UIng/RadioButtons.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_radio_buttons.cr)
