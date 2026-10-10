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

Choose `:horizontal` for a row or `:vertical` for a column. Children appear in `append` order.

The `stretchy` argument to `append` controls width in a horizontal Box and height in a vertical Box.

| Setting | Size along the layout direction |
| --- | --- |
| `stretchy: false` (default) | Keeps the size needed by its content; receives no extra space |
| `stretchy: true` | Uses the space left after non-stretchy children and gaps |

Multiple stretchy children receive equal widths (or heights in a vertical Box). There is no weight setting. With all children set to `false`, they stay at the left (or top), leaving extra space at the end. Minimum sizes follow children's size requirements.

Children generally fill the Box in the other direction: a child in a vertical Box can grow horizontally even with `false`. A Label in a horizontal Box is an exception; it keeps its natural height and is centered vertically.

## Gaps and outer margins

`padded: true` adds standard spacing between adjacent children. The default is `false`. Use the Window or Group's `margined` setting for outer margins.

```text
Window (margined: true)
+---------------------------------------+
|                margin                 |
|  +---------------------------------+  |
|  | [A]  gap  [B]  gap  [C]          |  |  Box (padded: true)
|  +---------------------------------+  |
|                margin                 |
+---------------------------------------+
```

Spacing follows the OS and display settings; pixel values cannot be specified. Change it later with `box.padded = true`. Nested Boxes each need their own setting.

## Nesting Boxes

This example stacks a search row, editor, and status label. Run it after `UIng.init`, with a window already created.

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

`stretchy` governs allocation from parent to child. If `body` is placed inside another vertical Box, append it with `stretchy: true` there as well to let it grow vertically.

See also the [horizontal Box example](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_box_horizontal.cr).

[API reference](../../api/UIng/Box.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_box_vertical.cr)
