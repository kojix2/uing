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

`left`は列、`top`は行で、どちらも0始まりです。`xspan`と`yspan`は使用する列数・行数を指定します。

![Gridの2列にまたがる配置と、拡張した領域内での中央配置・全幅配置の違い](../../images/grid-layout.svg)

```crystal
grid = UIng::Grid.new(padded: true)
grid.append(UIng::Button.new("Span"),
  left: 0, top: 1, xspan: 2, yspan: 1,
  hexpand: true, halign: :fill, vexpand: false, valign: :fill)
```

`hexpand`・`vexpand`は列・行の拡張、`halign`・`valign`は領域内の配置を指定します。図の破線は割り当て領域、青い矩形は子です。

| 横方向の指定 | 動作 |
| --- | --- |
| `hexpand: true, halign: :fill` | 列を広げ、子もその幅を満たす |
| `hexpand: true, halign: :center` | 列を広げ、子は必要な幅で中央に置く |
| `hexpand: false, halign: :fill` | 自身は列の拡張を要求せず、割り当てられた幅を満たす |

同じ列の別の子が列を広げれば、`hexpand: false`でも`:fill`の子は広がります。縦方向も同様です。`:start`・`:end`は必要なサイズで先頭・末尾に配置します。

`padded: true`でセル間に標準間隔を入れます。

## 関連作例

<div class="widget-screenshots">
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/calculator.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/calculator-ubuntu.png" alt="電卓" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/calculator.cr">電卓</a></figcaption></figure>
</div>

[APIリファレンス](../../api/UIng/Grid.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_grid.cr)
