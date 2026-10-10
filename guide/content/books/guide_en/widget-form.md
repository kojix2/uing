# Form

[日本語](../guide_ja/widget-form.html)

Form aligns labels and controls into native form rows.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-ubuntu.png" alt="Form on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-windows.png" alt="Form on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-macos.png" alt="Form on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_form" %}}

## Usage notes

Each `append` adds a label and control as one row. `stretchy: true` grows the control into the extra height; the default `false` keeps its required height. Both fill the input column horizontally.

![Form aligns labels and controls in columns; only the Notes row grows vertically.](../../images/form-layout.svg)

```crystal
form = UIng::Form.new(padded: true)
form.append("Name", UIng::Entry.new)
form.append("Notes", UIng::MultilineEntry.new, stretchy: true)
```

`padded: true` adds row and column spacing. To grow a Form inside a vertical Box, use `stretchy: true` in the Box's `append` too.

Labels are left-aligned on Windows and right-aligned on Linux and macOS (see [platform differences](controls-and-layout.html#platform-differences)).

[API reference](../../api/UIng/Form.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_form.cr)
