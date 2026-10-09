# Area scrolling and examples

[日本語](../guide_ja/area-scrolling-and-examples.html)

`Area.new(handler, width, height)` creates a scrolling Area with the supplied content dimensions. Unlike `Area.new(handler)`, do not use `params.area_width` or `params.area_height` to manage it; your application owns the content size.

```crystal
content_width = 2_000
content_height = 1_200
area = UIng::Area.new(handler, content_width, content_height)

# Update the dimensions after content expands.
content_width += 400
area.set_size(content_width, content_height)

# Bring a rectangle into view.
area.scroll_to(200, 100, 400, 300)
```

Use the clip rectangle in `draw` to paint only the visible region. For many shapes, images, or text layouts, reuse static Paths and Brushes and skip offscreen items.

## Next examples

- [area_breakout.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/area_breakout.cr): game loop and input
- [boid3d.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/boid3d.cr): drawing many objects
- [air_hockey](https://github.com/kojix2/uing/tree/main/examples/air_hockey): a practical separation of state, input, projection, and rendering

As an Area grows, separate model, input, and rendering into types or files. Keeping drawing functions read-only with respect to state makes redraw causes and resource lifetimes easier to follow.
