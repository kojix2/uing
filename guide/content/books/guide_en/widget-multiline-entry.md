# MultilineEntry

[日本語](../guide_ja/widget-multiline-entry.html)

MultilineEntry edits or displays text spanning multiple lines.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_multiline_entry-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_multiline_entry-ubuntu.png" alt="MultilineEntry on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_multiline_entry-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_multiline_entry-windows.png" alt="MultilineEntry on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_multiline_entry-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_multiline_entry-macos.png" alt="MultilineEntry on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_multiline_entry" %}}

## Usage notes

- Choose wrapping when constructing the control; it cannot be changed later.
- Use <code>append</code> for incremental output and <code>read_only</code> for a log viewer.

[API reference](../../api/UIng/MultilineEntry.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_multiline_entry.cr)
