# Tableの更新とライフタイム

[English](../guide_en/table-updates-and-lifetime.html)

## 変更をModelへ通知する

元データを変更しても、Tableは自動では再読込しません。操作後にModelへ該当する通知を送ります。

```crystal
# 追加後。new_indexは追加した行番号です。
rows << "New item"
model.row_inserted(rows.size - 1)

# 既存行の変更後。
rows[row] = "Renamed"
model.row_changed(row)

# 削除前の行番号を使い、元データを削除してから通知します。
rows.delete_at(row)
model.row_deleted(row)
```

複数行の変更では、元データと通知の順序を常に一致させます。ソートは全行の対応関係を変えるため、各行を`row_changed`で通知するか、用途に応じてModelを作り直す設計を選びます。

## 安全な破棄順

Modelを利用しているTableが残ったまま`model.free`を呼んではいけません。親コンテナからTableを外し、Tableを破棄してからModelを解放します。

```crystal
window.on_closing do
  window.delete(table) # Tableをウィンドウから外す
  table.destroy       # Modelより先にTableを破棄する
  model.free
  UIng.quit
  true
end
```

同じModelを複数のTableで使う場合は、すべてのTableを先に破棄します。破棄後にModelへ行通知を送らず、`Table::Value`や`Selection`をコールバック外へ保持しないでください。

この順序を守ると、画面を閉じる処理とデータ更新処理をそれぞれ小さく保てます。
