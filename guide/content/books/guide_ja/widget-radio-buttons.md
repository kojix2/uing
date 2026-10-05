# RadioButtons

[English](../guide_en/widget-radio-buttons.html)

RadioButtonsは複数の候補から最大1項目を選択します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_radio_buttons-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_radio_buttons-ubuntu.png" alt="RadioButtons on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_radio_buttons-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_radio_buttons-windows.png" alt="RadioButtons on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_radio_buttons-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_radio_buttons-macos.png" alt="RadioButtons on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_radio_buttons" %}}

## 使い方

- 選択位置は0始まりで、未選択時は<code>nil</code>です。
- <code>on_selected</code>には選択位置が渡されます。

[APIリファレンス](../../api/UIng/RadioButtons.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_radio_buttons.cr)
