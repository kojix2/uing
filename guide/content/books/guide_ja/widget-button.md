# Button

[English](../guide_en/widget-button.html)

Buttonはユーザーのクリックを受けて処理を実行するコントロールです。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_button-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_button-ubuntu.png" alt="Button on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_button-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_button-windows.png" alt="Button on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_button-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_button-macos.png" alt="Button on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_button" %}}

## 使い方

- クリックは<code>on_clicked</code>で処理します。
- 共通の<code>tooltip</code>、<code>enable</code>、<code>disable</code>も利用できます。

[APIリファレンス](../../api/UIng/Button.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_button.cr)
