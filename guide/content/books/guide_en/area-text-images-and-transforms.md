# Area text, images, and transforms

[日本語](../guide_ja/area-text-images-and-transforms.html)

## Text

Draw text in an Area with an `AttributedString` and a `TextLayout`. Set string attributes such as color and font, then draw the layout through the Context. `TextLayout.open` safely frees a temporary layout.

```crystal
string = UIng::Area::AttributedString.new("Hello, Area")
string.set_attribute(UIng::Area::Attribute.new_color(0.1, 0.1, 0.1, 1.0), 0, string.len)
font = UIng::FontDescriptor.new(family: "Sans", size: 14)
handler = UIng::Area::Handler.new

handler.draw do |_area, params|
  UIng::Area::Draw::TextLayout.open(
    string: string, default_font: font, width: 240,
    align: UIng::Area::Draw::TextAlign::Left
  ) do |layout|
    params.context.draw_text_layout(layout, 24, 24)
  end
end
```

For longer text, set an explicit layout width and alignment. Keep `string` and `font` while the Area uses them and `free` each at shutdown. A Context and temporary Layout must not escape `draw`.

## Images and transforms

Prepare a `UIng::Image`, then call `context.draw_image(image, x, y, width, height)` with the requested size. Pass the image's width and height for its native size. Keep an image after loading it rather than rebuilding it during every draw, and call `free` when the application no longer needs it.

`Area::Draw::Matrix` supports translation, scaling, rotation, and skew. Apply a Matrix to a limited Context scope and restore the original coordinate system afterwards; this makes several independently transformed elements easier to manage.

```crystal
# Inside draw; image is a UIng::Image prepared beforehand.
context = params.context
matrix = UIng::Area::Draw::Matrix.new.set_identity.translate(80, 40)
context.save
begin
  context.transform(matrix)
  context.draw_image(image, 0, 0, 100, 100)
ensure
  context.restore
end
```

- [basic_draw_text.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_draw_text.cr): attributed text
- [area_draw_image.cr](https://github.com/kojix2/uing/blob/main/examples/crimage/area_draw_image.cr): image drawing and scaling
- [area_matrix.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/area_matrix.cr): Matrix transforms
