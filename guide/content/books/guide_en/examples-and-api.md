# Examples and API Reference

[日本語](../guide_ja/examples-and-api.html)

Use the guide to learn the application structure, then use the API Reference
for the complete list of public types and methods.

- [API Reference](../../api/)
- [Control gallery](https://github.com/kojix2/uing/tree/main/examples/gallery)
- [UIng source code](https://github.com/kojix2/uing)
- [libui-ng](https://github.com/kojix2/libui-ng)

## Runnable examples

The gallery contains focused examples for individual controls, containers,
menus, tables, and custom drawing. Clone the repository, install its
development dependencies, and run the full gallery with:

<pre><code class="bash">
git clone https://github.com/kojix2/uing
cd uing
shards install
crystal run examples/gallery/control_gallery.cr
</code></pre>

Larger examples include:

- [MD5 Checker](https://github.com/kojix2/uing/tree/main/examples/md5_checker)
- [Video Player](https://github.com/kojix2/uing/tree/main/examples/video_player)
- [Air Hockey](https://github.com/kojix2/uing/tree/main/examples/air_hockey)

Start with the smallest example containing the control you need. Custom
drawing and tables have additional callbacks and lifetime requirements, so
their gallery examples are the best starting point.

## Packaging an application

The [MD5 Checker](https://github.com/kojix2/uing/tree/main/examples/md5_checker)
includes scripts for packaging a UIng application with the native libraries it
needs on Linux, macOS, and Windows. Use it as a starting point when preparing
an application for distribution.
