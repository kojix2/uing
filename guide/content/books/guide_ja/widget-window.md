# Window

[English](../guide_en/widget-window.html)

Windowはアプリケーションの最上位コンテナです。子コントロールは1つだけ持てるため、複数のコントロールはレイアウトコンテナにまとめます。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-ubuntu.png" alt="Window on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-windows.png" alt="Window on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-macos.png" alt="Window on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_window" %}}

## 使い方

- <code>on_closing</code>を登録し、<code>UIng.quit</code>でイベントループを終了します。
- <code>margined</code>、<code>content_size</code>、<code>fullscreen</code>、<code>borderless</code>でネイティブウィンドウを調整できます。

[APIリファレンス](../../api/UIng/Window.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_window.cr)
