# ImageView

[日本語](../guide_ja/widget-image-view.html)

ImageView displays a UIng Image using a native image view. UIng accepts raw pixels and does not depend on an image decoder. Add CrImage to your application's `shard.yml` to use the optional image and color helpers:

```yaml
dependencies:
  uing:
    github: kojix2/uing
  crimage:
    github: naqvis/crimage
```

```crystal
require "uing/crimage"

source = CrImage.read("photo.png")
view = UIng::ImageView.new(source, :fit)
view.image = CrImage.read("next.png")

# For an Area, Table, or Toolbar, keep the native image until it is no longer used.
image = UIng::Image.from_crimage(source)
# ... use image ...
image.free
```

## Runnable example

{{% shell command="sh scripts/render-example basic_image_view" %}}

## Usage notes

- Use <code>ContentMode::Fit</code> to scale the image to fit the view, or <code>ContentMode::Center</code> to display it centered at its natural size.
- Assign another Image with <code>image=</code>, or assign <code>nil</code> to clear the view.
- ImageView copies or retains its own native image. The source Image can therefore be freed immediately after construction or assignment.
- `require "uing"` works without CrImage; `require "uing/crimage"` adds the optional helpers. CrImage must be a dependency of the application using them.
- `UIng::Image.from_file(path)` detects the format from file contents. `CrImage.read(path)` uses the filename extension in this CrImage version.
- `UIng::Image.from_crimage`, `CrImage::Image#to_uing_image`, and `UIng::Image#append(CrImage::Image)` accept any CrImage image. The adapter converts pixels to premultiplied RGBA and handles nonzero image origins and subimages.
- `ImageView` releases its temporary UIng image after assignment. Images returned by `from_crimage`, `from_file`, or `to_uing_image` must be freed by the caller after their consumers are done with them.
- The same opt-in require adds CrImage color overloads for `ColorButton#set_color`, solid brushes, gradient stops, text attributes, and table color values. Use `CrImage::Color::NRGBA` for translucent UI colors. In the current CrImage version, `Color.parse` does not premultiply translucent RGBA correctly.

[ImageView API](../../api/UIng/ImageView.html) · [Image API](../../api/UIng/Image.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/crimage/basic_image_view.cr)
