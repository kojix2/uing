# ColorButton

[English](../guide_en/widget-color-button.html)

ColorButtonはOS標準のカラーピッカーを開き、RGBA色を保持します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_color_button-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_color_button-ubuntu.png" alt="ColorButton on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_color_button-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_color_button-windows.png" alt="ColorButton on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_color_button-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_color_button-macos.png" alt="ColorButton on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_color_button" %}}

## 使い方

- RGBA成分は<code>0.0</code>から<code>1.0</code>までの浮動小数点数です。
- <code>on_changed</code>には赤・緑・青・アルファ値が渡されます。

[APIリファレンス](../../api/UIng/ColorButton.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_color_button.cr)
