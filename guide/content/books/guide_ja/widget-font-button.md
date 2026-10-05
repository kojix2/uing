# FontButton

[English](../guide_en/widget-font-button.html)

FontButtonはOS標準のフォント選択画面を開き、FontDescriptorを返します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_font_button-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_font_button-ubuntu.png" alt="FontButton on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_font_button-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_font_button-windows.png" alt="FontButton on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_font_button-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_font_button-macos.png" alt="FontButton on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_font_button" %}}

## 使い方

- 新しい選択は<code>on_changed</code>で処理します。
- 記述子はコールバック内、またはブロック形式の<code>font</code>ヘルパー内で使用します。

[APIリファレンス](../../api/UIng/FontButton.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_font_button.cr)
