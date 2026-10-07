# Toolbar

[English](../guide_en/widget-toolbar.html)

Toolbarは、WindowにOS標準のコマンドボタンを追加します。通常のボタン、トグルボタン、区切り線、アイコン、ツールチップ、および複数の表示モードを利用できます。

Toolbarは`kojix2/libui-ng`固有の実験的な機能であり、今後変更される可能性があります。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_toolbar-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_toolbar-ubuntu.png" alt="Toolbar on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_toolbar-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_toolbar-windows.png" alt="Toolbar on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_toolbar-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_toolbar-macos.png" alt="Toolbar on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_toolbar" %}}

## 使い方

- すべての項目の追加と<code>display_mode</code>の設定は、ToolbarをWindowへ取り付ける前に行います。どちらも一度取り付けた後は変更できません。
- Toolbarは一度に1つのWindowにのみ取り付けられます。<code>toolbar.free</code>を呼ぶ前に、<code>window.toolbar</code>へ<code>nil</code>を代入して取り外します。
- Toolbarが使用している間はImageを保持し、Toolbarを解放した後でImageを解放します。
- <code>checked?</code>と<code>checked=</code>は、<code>append_toggle_button</code>で作成した項目でのみ利用できます。
- macOSでは、<code>IconAndTextHorizontal</code>も縦方向に表示されます。

[Toolbar API](../../api/UIng/Toolbar.html) · [ToolbarItem API](../../api/UIng/ToolbarItem.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_toolbar.cr)
