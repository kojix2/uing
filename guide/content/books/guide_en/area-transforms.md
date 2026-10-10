# Area coordinate transforms

[日本語](../guide_ja/area-transforms.html)

Pass a `Matrix` to `context.transform` to change the coordinate system for subsequent paths, text, and images.

## Transform scope

A transform remains on the Context, so normally wrap it in `save` and `restore`. Give each independent element its own scope to prevent transforms from affecting later drawing.

```crystal
context = params.context
matrix = UIng::Area::Draw::Matrix.new
matrix.set_identity
matrix.translate(160, 100)
matrix.rotate(160, 100, Math::PI / 6)

context.save
begin
  context.transform(matrix)
  context.draw_image(image, 0, 0, 80, 80)
ensure
  context.restore
end
```

## Matrix operations

| Method | Effect |
| --- | --- |
| `set_identity` | Restores the identity matrix |
| `translate(x, y)` | Moves coordinates |
| `scale(cx, cy, sx, sy)` | Scales around `(cx, cy)` |
| `rotate(cx, cy, angle)` | Rotates around `(cx, cy)`; `angle` is in radians |
| `skew(x, y, x_amount, y_amount)` | Skews around `(x, y)` |
| `multiply(other)` | Combines another Matrix |
| `invertible?` / `invert` | Tests for and applies an inverse |
| `transform_point` / `transform_size` | Transforms a coordinate or size |

Transformation order affects the result. Pass a point as the center to `rotate` or `scale` to operate around it.

A Matrix needs no explicit release. A Context is valid only during `draw`.

[area_matrix.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/area_matrix.cr) provides controls for translation, scaling, rotation, and skew.
