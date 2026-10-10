# ColorButton

[日本語](../guide_ja/widget-color-button.html)

ColorButton opens the platform color chooser and stores an RGBA color.

## Runnable example

{{% shell command="sh scripts/render-example basic_color_button" %}}

## Usage notes

- RGBA components are floating-point values from <code>0.0</code> through <code>1.0</code>.
- <code>on_changed</code> receives red, green, blue, and alpha values.
- With `require "uing/crimage"` and an application dependency on CrImage, both `color =` and `set_color` accept `CrImage::Color::Color`. The `color` getter still returns a numeric RGBA tuple; `color_crimage` returns a `CrImage::Color::NRGBA`. Use `NRGBA` for translucent colors; `Color.parse` currently constructs translucent `RGBA` values without premultiplying their channels.

```crystal
button.color = CrImage::Color::NRGBA.new(255, 0, 0, 128)
selected = button.color_crimage
```

[API reference](../../api/UIng/ColorButton.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/crimage/basic_color_button.cr)
