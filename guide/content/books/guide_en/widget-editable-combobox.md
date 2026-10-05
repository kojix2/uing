# EditableCombobox

[日本語](../guide_ja/widget-editable-combobox.html)

EditableCombobox accepts free-form text while offering suggested items.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_editable_combobox-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_editable_combobox-ubuntu.png" alt="EditableCombobox on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_editable_combobox-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_editable_combobox-windows.png" alt="EditableCombobox on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_editable_combobox-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_editable_combobox-macos.png" alt="EditableCombobox on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_editable_combobox" %}}

## Usage notes

- Read and write the current value through <code>text</code>.
- Use Combobox instead when selection indices and list mutation are required.

[API reference](../../api/UIng/EditableCombobox.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_editable_combobox.cr)
