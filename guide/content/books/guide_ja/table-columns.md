# Tableの列・編集・選択

[English](../guide_en/table-columns.html)

## モデル列と表示列

Modelの列はデータの型を定め、`append_*_column`はそれをどう表示・操作するかを定めます。[前ページの1列モデル](table-model.html)なら、表示列は次のように作れます。

```crystal
table = UIng::Table.new(model) do
  append_text_column("Language", 0, editable: :always)
end
```

複数列に拡張する場合、各表示列に対応する型のモデル列を先に用意します。

| 表示列 | 追加メソッド | データ列の型 |
| --- | --- | --- |
| テキスト | `append_text_column` | `String` |
| 画像 | `append_image_column` | `Image` |
| チェックボックス | `append_checkbox_column` | `Int` |
| 進捗バー | `append_progress_bar_column` | `Int` |
| ボタン | `append_button_column` | `String` |

画像付きテキストやチェックボックス付きテキストは複数のモデル列を参照します。テキスト色には`Color`列、編集可否やクリック可否を行ごとに切り替える場合は`Int`列を追加できます。列の引数は[APIリファレンス](../../api/UIng/Table.html)を確認してください。

## 編集を元データへ反映する

`editable: :always`を指定すると、ユーザー操作で`set_cell_value`が呼ばれます。そこでTableではなく元データを更新します。受け取る値はコールバックの外へ保存しません。

```crystal
set_cell_value do |row, column, value|
  next unless column == 0
  next unless name = value.try(&.string)

  rows[row] = name
end
```

このコードは前ページのHandlerに登録する`set_cell_value`を置き換えます。
ユーザーの編集をこのコールバックで受けた場合、`row_changed`を追加で呼ぶ必要はありません。アプリケーションの別の処理で値を変えた場合は通知します。

ボタン列のクリックでは`value`が`nil`になります。列番号を確認して、その行に対する操作を実行してください。編集できない列にも`set_cell_value`を用意しておくと、Handlerの役割が明確になります。

## 選択とクリック

選択は`selection_mode`で制御します。`on_selection_changed`の`Selection`はコールバック後に解放されるため、後で使うなら`selection.rows`で行番号を取り出します。

```crystal
table.selection_mode = UIng::Table::Selection::Mode::ZeroOrOne
table.on_selection_changed do |selection|
  selected_rows = selection.rows
  puts(selected_rows.empty? ? "未選択" : rows[selected_rows.first])
end

table.on_row_double_clicked do |row|
  puts "ダブルクリック: #{rows[row]}"
end
```

ヘッダークリックや行クリックのイベントも利用できます。ソートを実装する場合は元データを並べ替えた後、表示に変更を通知します。

発展例は[advanced_table.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/advanced_table.cr)を参照してください。
