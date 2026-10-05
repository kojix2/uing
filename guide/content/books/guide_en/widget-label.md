# Label

[日本語](../guide_ja/widget-label.html)

Label displays non-editable text.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_label-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_label-ubuntu.png" alt="Label on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_label-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_label-windows.png" alt="Label on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_label-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_label-macos.png" alt="Label on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_label" %}}

## Usage notes

- Update the caption with <code>text=</code>.
- Set <code>font_size</code> for a custom size and call <code>reset_font_size</code> to restore the native default.

[API reference](../../api/UIng/Label.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_label.cr)
