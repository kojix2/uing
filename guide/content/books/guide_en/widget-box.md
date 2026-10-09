# Box

[日本語](../guide_ja/widget-box.html)

Box arranges children in a horizontal or vertical sequence.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-ubuntu.png" alt="Box on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-windows.png" alt="Box on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-macos.png" alt="Box on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_box_vertical" %}}

## Usage notes

- Choose <code>:horizontal</code> or <code>:vertical</code> when constructing it. You can also use <code>UIng::Orientation::Horizontal</code> or <code>UIng::Orientation::Vertical</code>.
- Pass <code>stretchy: true</code> to let a child consume remaining space; <code>padded</code> adds native spacing.

See also the [horizontal Box example](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_box_horizontal.cr).

[API reference](../../api/UIng/Box.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_box_vertical.cr)
