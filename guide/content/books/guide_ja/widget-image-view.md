# ImageView

[English](../guide_en/widget-image-view.html)

ImageViewは、UIngのImageをOS標準の画像ビューへ表示します。UIngは生の画素を受け取り、画像デコーダーには依存しません。サンプルでは[CrImage](https://github.com/naqvis/crimage)で画像ファイルを読み込み、UIngが要求するpremultiplied RGBA形式へ画素を変換しています。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_image_view-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_image_view-ubuntu.png" alt="ImageView on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_image_view-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_image_view-windows.png" alt="ImageView on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_image_view-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_image_view-macos.png" alt="ImageView on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_image_view" %}}

## 使い方

- <code>ContentMode::Fit</code>はビューに収まるよう画像を拡大縮小し、<code>ContentMode::Center</code>は画像を本来のサイズで中央に表示します。
- <code>image=</code>で別のImageを設定できます。<code>nil</code>を代入すると表示を消去します。
- ImageViewはネイティブ画像を内部でコピーまたは保持します。そのため、構築または代入の直後に元のImageを解放できます。
- <code>Image#append</code>へ渡す画素はpremultiplied RGBA形式である必要があります。CrImageの<code>to_rgba8</code>でこの形式へ変換できます。
- CrImageが必要なのは、このサンプルや画像デコードにCrImageを選んだアプリケーションだけです。UIng本体の実行時依存ではありません。

[ImageView API](../../api/UIng/ImageView.html) · [Image API](../../api/UIng/Image.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_image_view.cr)
