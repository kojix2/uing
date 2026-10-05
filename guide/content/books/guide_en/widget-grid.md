# Grid

[日本語](../guide_ja/widget-grid.html)

Grid places controls at explicit rows and columns with spans, expansion, and alignment.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_grid-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_grid-ubuntu.png" alt="Grid on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_grid-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_grid-windows.png" alt="Grid on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_grid-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_grid-macos.png" alt="Grid on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_grid" %}}

## Usage notes

- Coordinates are zero-based; <code>xspan</code> and <code>yspan</code> control cell spanning.
- Expansion and alignment are configured independently for each axis.

## Related example

<div class="widget-screenshots">
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/calculator.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/calculator-ubuntu.png" alt="Calculator" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/calculator.cr">Calculator</a></figcaption></figure>
</div>

[API reference](../../api/UIng/Grid.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_grid.cr)
