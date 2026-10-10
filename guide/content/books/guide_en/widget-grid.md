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

`left` is the column and `top` is the row, both zero-based. `xspan` and `yspan` specify how many columns and rows a control occupies.

![A Grid control spanning two columns, and centered versus filled alignment within an expanded allocation.](../../images/grid-layout.svg)

```crystal
grid = UIng::Grid.new(padded: true)
grid.append(UIng::Button.new("Span"),
  left: 0, top: 1, xspan: 2, yspan: 1,
  hexpand: true, halign: :fill, vexpand: false, valign: :fill)
```

`hexpand` and `vexpand` expand columns and rows; `halign` and `valign` set placement within them. Dashed outlines show allocated space; blue rectangles show children.

| Horizontal settings | Behavior |
| --- | --- |
| `hexpand: true, halign: :fill` | Expands the column and fills its width with the child |
| `hexpand: true, halign: :center` | Expands the column and centers the child at its required width |
| `hexpand: false, halign: :fill` | Does not request column expansion, but fills the allocated width |

If another child expands the same column, a child with `hexpand: false` and `:fill` also grows. The vertical direction works the same way. `:start` and `:end` keep the required size at the start or end of the allocation.

`padded: true` adds standard spacing between cells.

## Related example

<div class="widget-screenshots">
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/calculator.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/calculator-ubuntu.png" alt="Calculator" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/calculator.cr">Calculator</a></figcaption></figure>
</div>

[API reference](../../api/UIng/Grid.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_grid.cr)
