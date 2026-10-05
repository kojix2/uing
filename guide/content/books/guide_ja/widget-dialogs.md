# Dialogs

[English](../guide_en/widget-dialogs.html)

Windowはメッセージ、エラー、ファイル選択、フォルダ選択、保存のネイティブダイアログを提供します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box-ubuntu.png" alt="Dialogs on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box-windows.png" alt="Dialogs on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box-macos.png" alt="Dialogs on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_file_dialog" %}}

## 使い方

- モーダル状態とフォーカスを正しく保つため、親となるWindowからダイアログを呼び出します。
- <code>open_file</code>、<code>open_folder</code>、<code>save_file</code>はキャンセル時に<code>nil</code>を返します。



[APIリファレンス](../../api/UIng/Window.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_file_dialog.cr)
