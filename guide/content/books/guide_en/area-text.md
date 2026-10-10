# Area text

[日本語](../guide_ja/area-text.html)

Use an `AttributedString` for text and its attributes, then create a `TextLayout` to draw it.

## Drawing workflow

| Stage | Type | Purpose |
| --- | --- | --- |
| Text | `AttributedString` | Holds text and range-specific attributes |
| Default font | `FontDescriptor` | Font for unstyled text |
| Layout | `TextLayout` | Determines wrapping, alignment, and drawn size |
| Drawing | `draw_text_layout` | Draws the layout at a position |

```crystal
text = UIng::Area::AttributedString.new("Hello, Area")
text.set_attribute(
  UIng::Area::Attribute.new_color(0.1, 0.2, 0.6, 1.0),
  0, text.len
)
font = UIng::FontDescriptor.new(family: "Sans", size: 14)

handler.draw do |_area, params|
  UIng::Area::Draw::TextLayout.open(
    string: text, default_font: font,
    width: 240, align: :left
  ) do |layout|
    params.context.draw_text_layout(layout, 24, 24)
  end
end
```

`TextLayout.open` frees the layout when its block ends. A Context is valid only during `draw`.

## Attributes

`set_attribute(attribute, start, end_)` applies an attribute to a byte range. For UTF-8 text, do not use character counts as byte positions; use `String#bytesize`, `AttributedString#len`, `byte_index_to_grapheme`, and `grapheme_to_byte_index` to work at valid boundaries.

| Attribute constructor | Purpose |
| --- | --- |
| `new_family("Sans")` / `new_size(16)` | Font family and size |
| `new_weight(:bold)` / `new_italic(:italic)` | Weight and italic style |
| `new_stretch(:condensed)` | Width variant |
| `new_color(r, g, b, a)` | Text color |
| `new_background(r, g, b, a)` | Background color |
| `new_underline(:single)` | Underline |
| `new_underline_color(:custom, r, g, b, a)` | Underline color |
| `new_features(features)` | OpenType features |

```crystal
start = text.len
text.append_unattributed(" important")
text.set_attribute(UIng::Area::Attribute.new_weight(:bold), start, text.len)
text.set_attribute(UIng::Area::Attribute.new_underline(:single), start, text.len)
```

An Attribute passed to `set_attribute` transfers ownership to the `AttributedString`. Do not reuse or free it. Create a new Attribute for every range.

## Width, alignment, and size

`width` is the maximum width for wrapping. `align` accepts `:left`, `:center`, or `:right`. `layout.extents` returns the layout width and height.

```crystal
UIng::Area::Draw::TextLayout.open(
  string: text, default_font: font,
  width: params.area_width - 48,
  align: :center
) do |layout|
  width, height = layout.extents
  params.context.draw_text_layout(layout, 24, 24)
end
```

`TextLayout` copies its text and font at creation. A static layout can be retained and redrawn; call `free` when done. Also free retained `AttributedString` and `FontDescriptor` values when the application exits.

[basic_draw_text.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_draw_text.cr) demonstrates attributed text.
