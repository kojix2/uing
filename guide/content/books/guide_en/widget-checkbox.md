# Checkbox

[日本語](../guide_ja/widget-checkbox.html)

Checkbox represents an independent on/off choice.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_checkbox-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_checkbox-ubuntu.png" alt="Checkbox on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_checkbox-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_checkbox-windows.png" alt="Checkbox on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_checkbox-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_checkbox-macos.png" alt="Checkbox on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_checkbox" %}}

## Usage notes

- Read the state with <code>checked?</code> and set it with <code>checked=</code>.
- <code>on_toggled</code> receives the new Boolean state.

[API reference](../../api/UIng/Checkbox.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_checkbox.cr)
