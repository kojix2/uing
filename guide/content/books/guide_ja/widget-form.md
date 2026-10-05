# Form

[English](../guide_en/widget-form.html)

Formはラベルとコントロールをネイティブなフォーム行として整列します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-ubuntu.png" alt="Form on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-windows.png" alt="Form on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-macos.png" alt="Form on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_form" %}}

## 使い方

- <code>append</code>でラベルと1つのコントロールを行として追加します。
- 複数行入力などを広げる場合は<code>stretchy: true</code>を指定します。



[APIリファレンス](../../api/UIng/Form.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_form.cr)
