# ダイアログ

[English](../guide_en/widget-dialogs.html)

Windowはメッセージ、エラー、ファイル選択、フォルダ選択、保存のネイティブダイアログを提供します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_file_dialog-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_file_dialog-ubuntu.png" alt="File dialog on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_file_dialog-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_file_dialog-windows.png" alt="File dialog on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_file_dialog-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_file_dialog-macos.png" alt="File dialog on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_file_dialog" %}}

## 種類

### メッセージ

| メソッド | 用途 | 戻り値 |
| --- | --- | --- |
| <code>msg_box(title, description)</code> | 情報や確認事項を表示します。 | <code>Nil</code> |
| <code>msg_box_error(title, description)</code> | エラーを表示します。 | <code>Nil</code> |

### ファイルとフォルダ

| メソッド | 用途 | 戻り値 |
| --- | --- | --- |
| <code>open_file</code> | 開くファイルを選択します。 | 選択したパス、またはキャンセル時は<code>nil</code> |
| <code>save_file</code> | 保存先のファイルを選択します。 | 選択したパス、またはキャンセル時は<code>nil</code> |
| <code>open_folder</code> | 開くフォルダを選択します。 | 選択したパス、またはキャンセル時は<code>nil</code> |

## 使い方

- モーダル状態とフォーカスを正しく保つため、親となるWindowからダイアログを呼び出します。
- <code>open_file</code>、<code>open_folder</code>、<code>save_file</code>はキャンセル時に<code>nil</code>を返します。
- 表示や細部の操作はOSのネイティブダイアログに従います。



[APIリファレンス](../../api/UIng/Window.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_file_dialog.cr)
