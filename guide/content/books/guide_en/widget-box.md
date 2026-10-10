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

## Direction and stretching

Children appear in `append` order; set `stretchy` for each child.

| Box direction | `stretchy: false` (default) | `stretchy: true` | Other direction |
| --- | --- | --- | --- |
| `:horizontal` | Keeps the required width | Receives remaining width | Height generally follows the Box |
| `:vertical` | Keeps the required height | Receives remaining height | Width generally follows the Box |

Multiple stretchy children receive equal widths (or heights in a vertical Box). There is no weight setting. With all children set to `false`, they stay at the left (or top), leaving extra space at the end. Minimum sizes follow children's size requirements.

![A horizontal Box with only B stretchy, compared with equal widths for stretchy children B and C.](../../images/box-stretchy.svg)

A Label in a horizontal Box keeps its natural height and is centered vertically. Internal appearance has [platform differences](controls-and-layout.html#platform-differences). Use [Grid](widget-grid.html) to control expansion and alignment independently.

## Gaps and outer margins

`padded: true` adds gaps between children; the Window or Group's `margined` sets outer margins. `padded` defaults to `false`.

![Window margined adds space around the Box; Box padded adds gaps between children A, B, and C.](../../images/box-spacing.svg)

Spacing follows the OS and display settings, not a pixel value. Change it with `box.padded = true`; nested Boxes have independent settings.

## Nesting Boxes

Run this example after `UIng.init`, with a window already created.

```crystal
search = UIng::Box.new(:horizontal, padded: true)
search.append(UIng::Label.new("Search"))
search.append(UIng::Entry.new, stretchy: true) # Grows horizontally
search.append(UIng::Button.new("Search"))

editor = UIng::MultilineEntry.new
status = UIng::Label.new("Ready")

body = UIng::Box.new(:vertical, padded: true)
body.append(search)                # Only the height the row needs
body.append(editor, stretchy: true) # Uses the remaining height
body.append(status)

window.margined = true
window.child = body
```

Widening the window expands the search field and editor; increasing its height expands the editor. The search row and status label keep their heights.

If `body` is inside another vertical Box, append it with `stretchy: true` there as well to let it grow vertically.

See also the [horizontal Box example](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_box_horizontal.cr).

[API reference](../../api/UIng/Box.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_box_vertical.cr)
