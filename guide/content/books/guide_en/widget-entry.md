# Entry

[日本語](../guide_ja/widget-entry.html)

Entry is a single-line text field with standard, search, and password variants.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_entry-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_entry-ubuntu.png" alt="Entry on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_entry-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_entry-windows.png" alt="Entry on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_entry-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_entry-macos.png" alt="Entry on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_entry" %}}

## Usage notes

- Pass <code>:search</code> or <code>:password</code> to select a native variant. The typed <code>UIng::Entry::Type</code> values are also accepted.
- Use <code>read_only</code> for text that should be selectable but not editable.

[API reference](../../api/UIng/Entry.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_entry.cr)
