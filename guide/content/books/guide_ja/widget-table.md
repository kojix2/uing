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

## 基本構成

`Table::Model::Handler`がデータを提供し、`Table::Model`を介して`Table`に表示します。初期化とウィンドウ作成は上の実行例を参照してください。

```crystal
data = %w[Windows macOS Ubuntu]
handler = UIng::Table::Model::Handler.new do
  num_columns { 1 }
  column_type { |_column| UIng::Table::Value::Type::String }
  num_rows { data.size }
  cell_value { |row, _column| UIng::Table::Value.new(data[row]) }
  set_cell_value { |_row, _column, _value| }
end

model = UIng::Table::Model.new(handler)
table = UIng::Table.new(model) do
  append_text_column("OS", 0, editable: :never)
end
window.child = table
```

行・モデル列の番号は0始まりです。`append_text_column`の`0`は表示するモデル列を指定します。モデルの列数と型は作成時に固定され、セル値は列の型に合わせます。

## この章の進め方

このページでは最小構成を扱います。続くページで、モデルコールバックと値の所有権、列の種類・編集・選択、データ更新と破棄順を順に説明します。

- [モデルとデータ供給](table-model.html): ModelとHandlerの役割、型、`Table::Value`の所有権
- [列・編集・選択](table-columns.html): 列の追加、編集可能なセル、選択とクリックイベント
- [更新とライフタイム](table-updates-and-lifetime.html): 行通知と安全な解放

## 関連作例

<div class="widget-screenshots">
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/csv_viewer.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/csv_viewer-ubuntu.png" alt="CSV viewer" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/csv_viewer.cr">CSV viewer</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/advanced_table.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/advanced_table-ubuntu.png" alt="高度なTable" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/advanced_table.cr">高度なTable</a></figcaption></figure>
</div>

[APIリファレンス](../../api/UIng/Table.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_table.cr)
