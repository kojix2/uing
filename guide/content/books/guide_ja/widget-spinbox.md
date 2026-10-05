# Spinbox

[English](../guide_en/widget-spinbox.html)

Spinboxは入力欄と増減ボタンで整数を選択します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_spinbox-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_spinbox-ubuntu.png" alt="Spinbox on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_spinbox-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_spinbox-windows.png" alt="Spinbox on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_spinbox-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_spinbox-macos.png" alt="Spinbox on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_spinbox" %}}

## 使い方

- 最小値、最大値、必要なら初期値を作成時に渡します。
- <code>on_changed</code>には現在の整数値が渡されます。

[APIリファレンス](../../api/UIng/Spinbox.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_spinbox.cr)
