# Slider

[English](../guide_en/widget-slider.html)

Sliderは指定範囲内の整数をスライド操作で選択します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_slider-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_slider-ubuntu.png" alt="Slider on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_slider-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_slider-windows.png" alt="Slider on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_slider-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_slider-macos.png" alt="Slider on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_slider" %}}

## 使い方

- 連続更新には<code>on_changed</code>、ドラッグ終了時には<code>on_released</code>を使います。
- <code>has_tool_tip</code>で値のネイティブツールチップを切り替えます。

[APIリファレンス](../../api/UIng/Slider.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_slider.cr)
