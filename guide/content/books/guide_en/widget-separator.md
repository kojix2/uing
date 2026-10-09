# Separator

[日本語](../guide_ja/widget-separator.html)

Separator draws a native horizontal or vertical divider.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_separator-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_separator-ubuntu.png" alt="Separator on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_separator-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_separator-windows.png" alt="Separator on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_separator-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_separator-macos.png" alt="Separator on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_separator" %}}

## Usage notes

- Construct it with <code>:horizontal</code> or <code>:vertical</code>. The typed <code>UIng::Orientation</code> values are also accepted.
- Place a vertical separator inside a horizontal Box and a horizontal separator inside a vertical Box.

[API reference](../../api/UIng/Separator.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_separator.cr)
