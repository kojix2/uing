# ImageView

[日本語](../guide_ja/widget-image-view.html)

ImageView displays a UIng Image using a native image view. UIng accepts raw pixels and does not depend on an image decoder. The example uses [CrImage](https://github.com/naqvis/crimage) to decode an image file and convert its pixels to the premultiplied RGBA format expected by UIng.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_image_view-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_image_view-ubuntu.png" alt="ImageView on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_image_view-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_image_view-windows.png" alt="ImageView on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_image_view-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_image_view-macos.png" alt="ImageView on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_image_view" %}}

## Usage notes

- Use <code>ContentMode::Fit</code> to scale the image to fit the view, or <code>ContentMode::Center</code> to display it centered at its natural size.
- Assign another Image with <code>image=</code>, or assign <code>nil</code> to clear the view.
- ImageView copies or retains its own native image. The source Image can therefore be freed immediately after construction or assignment.
- Pixels passed to <code>Image#append</code> must be premultiplied RGBA. CrImage's <code>to_rgba8</code> provides this representation.
- CrImage is needed only by the example and applications that choose it for image decoding; it is not a runtime dependency of UIng.

[ImageView API](../../api/UIng/ImageView.html) · [Image API](../../api/UIng/Image.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_image_view.cr)
