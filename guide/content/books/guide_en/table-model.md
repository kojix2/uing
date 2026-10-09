# Table models and data

[日本語](../guide_ja/table-model.html)

A `Table` does not store cell values. Your application owns an array or records, and a `Table::Model::Handler` exposes that data through callbacks. This separation keeps display code separate from data updates.

## The model contract

Register four callbacks on the Handler:

- `num_columns`: the number of model columns
- `column_type`: a `Table::Value::Type` for every model column
- `num_rows`: the current number of rows
- `cell_value`: the value for a requested row and column

The schema (column count and types) is sealed when the Handler is first given to a Model. Row count and cell values continue to be queried, so their closures should read your backing data.

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

Row and model-column indices are zero-based. A display column selects its model column with an argument such as `append_text_column("Name", 0, ...)`.

## Value types and ownership

The type returned by `column_type` must match the `Table::Value` returned by `cell_value`. Common types are `String`, `Image`, `Int`, and `Color`. Checkboxes and progress bars use `Int`.

Return a **new** `Table::Value` every time `cell_value` runs. Ownership transfers to libui-ng, so do not reuse or `free` that value. Conversely, a value received by `set_cell_value` is borrowed and may be read only during that callback.

The Model retains its Handler. Your application must also keep the backing data captured by the Handler usable while the Table is in use.

Next, map model columns to native display columns and add editing and selection: [Columns, editing, and selection](table-columns.html).
