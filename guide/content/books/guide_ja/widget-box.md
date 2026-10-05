# Box

[English](../guide_en/widget-box.html)

Boxは子コントロールを水平または垂直に並べます。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-ubuntu.png" alt="Box on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-windows.png" alt="Box on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-macos.png" alt="Box on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_box_vertical" %}}

## 使い方

- 作成時に<code>:horizontal</code>または<code>:vertical</code>を選びます。
- <code>stretchy: true</code>で残りの領域を使わせ、<code>padded</code>でネイティブな間隔を加えます。

[水平Boxの例](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_box_horizontal.cr)も参照してください。

[APIリファレンス](../../api/UIng/Box.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_box_vertical.cr)
