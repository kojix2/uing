# Table

[English](../guide_en/widget-table.html)

Tableはモデルの行データを、テキスト・画像・チェック・進捗・ボタンなどの列で表示します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-ubuntu.png" alt="Table on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-windows.png" alt="Table on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-macos.png" alt="Table on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_table" %}}

## 使い方

- Handlerがスキーマとセル値を提供し、行の追加・変更・削除後はModelへ通知します。
- Modelを解放する前にすべてのTableを切り離して破棄します。コールバックのSelectionは自動解放されます。

## 関連作例

<div class="widget-screenshots">
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/csv_viewer.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/csv_viewer-ubuntu.png" alt="CSV viewer" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/csv_viewer.cr">CSV viewer</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/advanced_table.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/advanced_table-ubuntu.png" alt="高度なTable" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/advanced_table.cr">高度なTable</a></figcaption></figure>
</div>

[APIリファレンス](../../api/UIng/Table.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_table.cr)
