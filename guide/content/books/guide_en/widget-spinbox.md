# Spinbox

[日本語](../guide_ja/widget-spinbox.html)

Spinbox selects an integer using an editable field and step buttons.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_spinbox-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_spinbox-ubuntu.png" alt="Spinbox on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_spinbox-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_spinbox-windows.png" alt="Spinbox on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_spinbox-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_spinbox-macos.png" alt="Spinbox on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_spinbox" %}}

## Usage notes

- Provide the minimum, maximum, and optional initial value when constructing it.
- <code>on_changed</code> receives the current integer.

[API reference](../../api/UIng/Spinbox.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_spinbox.cr)
