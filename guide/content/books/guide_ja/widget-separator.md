# Separator

[English](../guide_en/widget-separator.html)

Separatorは水平または垂直のネイティブ区切り線を描画します。単独では区切る対象がないため、Labelなどのコントロールを含むBox内で使います。実行例では両方の向きを示します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_separator-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_separator-ubuntu.png" alt="Separator on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_separator-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_separator-windows.png" alt="Separator on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_separator-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_separator-macos.png" alt="Separator on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_separator" %}}

## 使い方

- <code>:horizontal</code>または<code>:vertical</code>を指定します。型付きの<code>UIng::Orientation</code>も使用できます。
- 垂直線は水平Box、水平線は垂直Boxの中に配置します。
- 区切り線の前後にLabelなどを配置して、関連するコントロールのまとまりを視覚的に分けます。

[APIリファレンス](../../api/UIng/Separator.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_separator.cr)
