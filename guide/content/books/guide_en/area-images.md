# Area images

[日本語](../guide_ja/area-images.html)

Create and retain a `UIng::Image`, then call `context.draw_image` inside `draw`. Do not rebuild an image for every draw callback.

## Creating and drawing an image

| API | Purpose |
| --- | --- |
| `Image.new(width, height)` | Creates an empty image with logical dimensions |
| `image.size` / `image.width` / `image.height` | Returns logical dimensions in points |
| `image.append(pixels, pixel_width, pixel_height, byte_stride)` | Adds premultiplied RGBA pixels |
| `draw_image(image, x, y, width, height)` | Draws into a rectangle |
| `image.free` | Releases an unused image |

`draw_image` width and height must be finite and positive. They determine display size, so preserve aspect ratio in the caller.

```crystal
handler.draw do |_area, params|
  params.context.draw_image(image, 24, 24, 128, 128)
end
```

## Construction blocks

Use an `Image.new` block to add image representations.

```crystal
image = UIng::Image.new(16, 16) do
  append(pixels_1x, 16, 16, 64)
  append(pixels_2x, 32, 32, 128)
end
```

`ImageBuffer.new` also accepts a block to configure a fixed-resolution buffer's initial pixels. The same form works with `ImageBuffer.new(source)` for CrImage images.

```crystal
buffer = UIng::ImageBuffer.new(1, 1) do
  update(Bytes[255, 0, 0, 255])
end
```

Both forms also pass the new object as `|image|` or `|buffer|`. They return that object regardless of the block's result and free it if the configuration block raises. After successful construction, the caller owns the object and must call `free` when finished. `ImageBuffer.open` uses ordinary block arguments and frees the buffer on block exit.

## Loading from a file

With `require "uing/crimage"`, create a `UIng::Image` from a file or CrImage image.

```crystal
require "uing/crimage"

image = UIng::Image.from_file("logo.png")

window.on_closing do
  image.free
  UIng.quit
  true
end
```

| API | Purpose |
| --- | --- |
| `UIng::Image.from_file(path)` | Loads a file into a native image |
| `source.to_uing_image` | Converts a `CrImage::Image` to a native image |
| `image.append(source)` | Adds a CrImage representation to an existing image |

To add a higher-resolution representation, use `append` on the same Image. The caller owns every created Image and calls `free` when it is no longer needed.

[area_draw_image.cr](https://github.com/kojix2/uing/blob/main/examples/crimage/area_draw_image.cr) demonstrates image drawing and scaling.
