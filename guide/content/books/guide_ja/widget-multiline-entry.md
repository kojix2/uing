# MultilineEntry

[English](../guide_en/widget-multiline-entry.html)

MultilineEntryは複数行のテキストを編集または表示します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_multiline_entry-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_multiline_entry-ubuntu.png" alt="MultilineEntry on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_multiline_entry-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_multiline_entry-windows.png" alt="MultilineEntry on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_multiline_entry-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_multiline_entry-macos.png" alt="MultilineEntry on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_multiline_entry" %}}

## 使い方

- 折返しの有無は作成時に選び、後からは変更できません。
- 逐次出力には<code>append</code>、ログ表示には<code>read_only</code>が便利です。

[APIリファレンス](../../api/UIng/MultilineEntry.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_multiline_entry.cr)
