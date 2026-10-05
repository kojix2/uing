# Tab

[English](../guide_en/widget-tab.html)

Tabはコントロールを名前付きの複数ページに整理します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-ubuntu.png" alt="Tab on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-windows.png" alt="Tab on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-macos.png" alt="Tab on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_tab" %}}

## 使い方

- ページは<code>append</code>または<code>insert_at</code>で追加します。
- <code>selected</code>で選択ページを読み書きし、変更は<code>on_selected</code>で受け取ります。



[APIリファレンス](../../api/UIng/Tab.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_tab.cr)
