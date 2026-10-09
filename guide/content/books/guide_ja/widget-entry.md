# Entry

[English](../guide_en/widget-entry.html)

Entryは通常・検索・パスワードの各形式を持つ1行テキスト入力です。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_entry-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_entry-ubuntu.png" alt="Entry on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_entry-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_entry-windows.png" alt="Entry on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_entry-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_entry-macos.png" alt="Entry on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_entry" %}}

## 使い方

- <code>:search</code>または<code>:password</code>でネイティブ形式を選択します。型付きの<code>UIng::Entry::Type</code>も使用できます。
- 選択はできても編集させない場合は<code>read_only</code>を使います。

[APIリファレンス](../../api/UIng/Entry.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_entry.cr)
