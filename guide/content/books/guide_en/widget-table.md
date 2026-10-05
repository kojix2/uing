# Table

[日本語](../guide_ja/widget-table.html)

Table presents model-backed rows and native text, image, checkbox, progress, and button columns.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-ubuntu.png" alt="Table on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-windows.png" alt="Table on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-macos.png" alt="Table on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_table" %}}

## Usage notes

- The Handler defines the schema and supplies cell values; notify the Model after inserting, changing, or deleting rows.
- Detach and destroy every Table before freeing its Model. Callback selections are freed automatically.

## Related examples

<div class="widget-screenshots">
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/csv_viewer.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/csv_viewer-ubuntu.png" alt="CSV viewer" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/csv_viewer.cr">CSV viewer</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/advanced_table.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/advanced_table-ubuntu.png" alt="Advanced Table" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/advanced_table.cr">Advanced Table</a></figcaption></figure>
</div>

[API reference](../../api/UIng/Table.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_table.cr)
