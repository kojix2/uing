# Tableのモデルとデータ供給

[English](../guide_en/table-model.html)

`Table`はセルの値を保持しません。アプリケーションが保持する配列やレコードを、`Table::Model::Handler`のコールバック経由で読み取ります。この分離により、表示とデータの更新を別々に扱えます。

## モデルの契約

Handlerには次の4つを登録します。

- `num_columns`: モデル列数
- `column_type`: 各モデル列の`Table::Value::Type`
- `num_rows`: 現在の行数
- `cell_value`: 指定された行・列の値

スキーマ（列数と列型）は、Handlerを最初にModelへ渡した時点で固定されます。行数とセル値はその後も問い合わせられるため、元データを参照するクロージャにします。

```crystal
rows = ["Crystal", "Ruby"]

handler = UIng::Table::Model::Handler.new do
  num_columns { 1 }
  column_type { |_column| UIng::Table::Value::Type::String }
  num_rows { rows.size }
  cell_value do |row, _column|
    UIng::Table::Value.new(rows[row])
  end
  set_cell_value { |_row, _column, _value| }
end

model = UIng::Table::Model.new(handler)
```

行番号とモデル列番号は0始まりです。表示列が参照するモデル列は、`append_text_column("Name", 0, ...)`のように指定します。

## 値の型と所有権

`column_type`が返す型と`cell_value`が返す`Table::Value`の型は一致させます。主な型は`String`、`Image`、`Int`、`Color`です。チェックボックスと進捗バーは`Int`を使います。

`cell_value`は呼ばれるたびに**新しい**`Table::Value`を返します。返した値の所有権はlibui-ngへ移るため、再利用や`free`はしません。一方、`set_cell_value`で受け取る値は借用値であり、そのコールバック内だけで読み取ります。

`Handler`は`Model`が保持します。ただし、Handlerのクロージャが参照する元データは、Tableを使う間はアプリケーション側でも有効に保ちます。

次は、モデル列をネイティブの表示列へ対応付け、編集と選択を追加します: [列・編集・選択](table-columns.html)。
