# Menu

[English](../guide_en/widget-menu.html)

MenuはアプリケーションメニューとOS標準のメニュー項目を作成します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-ubuntu.png" alt="Menu on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-windows.png" alt="Menu on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-macos.png" alt="Menu on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_menu" %}}

## 使い方

- 最初のWindowを作る前にすべてのMenuを構築し、Windowへ<code>menubar: true</code>を指定します。
- プラットフォーム側の操作ではWindowがない場合があるため、コールバックには省略可能なWindowが渡されます。



[APIリファレンス](../../api/UIng/Menu.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_menu.cr)
