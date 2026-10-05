# Checkbox

[English](../guide_en/widget-checkbox.html)

Checkboxは独立したオン／オフの選択を表します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_checkbox-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_checkbox-ubuntu.png" alt="Checkbox on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_checkbox-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_checkbox-windows.png" alt="Checkbox on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_checkbox-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_checkbox-macos.png" alt="Checkbox on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_checkbox" %}}

## 使い方

- 状態は<code>checked?</code>で読み、<code>checked=</code>で設定します。
- <code>on_toggled</code>には変更後の真偽値が渡されます。

[APIリファレンス](../../api/UIng/Checkbox.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_checkbox.cr)
