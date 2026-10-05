# Grid

[English](../guide_en/widget-grid.html)

Gridは行・列・結合範囲・拡張・配置を指定してコントロールを置きます。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_grid-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_grid-ubuntu.png" alt="Grid on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_grid-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_grid-windows.png" alt="Grid on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_grid-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_grid-macos.png" alt="Grid on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_grid" %}}

## 使い方

- 座標は0始まりで、<code>xspan</code>と<code>yspan</code>がセル結合範囲です。
- 拡張と配置は水平・垂直それぞれ独立して指定します。

## 関連作例

<div class="widget-screenshots">
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/calculator.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/calculator-ubuntu.png" alt="電卓" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/calculator.cr">電卓</a></figcaption></figure>
</div>

[APIリファレンス](../../api/UIng/Grid.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_grid.cr)
