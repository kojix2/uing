# Table columns, editing, and selection

[日本語](../guide_ja/table-columns.html)

## Model columns and display columns

Model columns define the data types. `append_*_column` defines how a native Table displays and interacts with that data. With the [one-column model from the previous page](table-model.html), create a display column like this:

```crystal
table = UIng::Table.new(model) do
  append_text_column("Language", 0, editable: :always)
end
```

For more columns, first add model columns of the matching types.

| Display column | Method | Data column type |
| --- | --- | --- |
| Text | `append_text_column` | `String` |
| Image | `append_image_column` | `Image` |
| Checkbox | `append_checkbox_column` | `Int` |
| Progress bar | `append_progress_bar_column` | `Int` |
| Button | `append_button_column` | `String` |

Image-and-text and checkbox-and-text columns refer to multiple model columns. Add a `Color` column for text color, or an `Int` column to control per-row editability or clickability. See the [API reference](../../api/UIng/Table.html) for column arguments.

## Apply edits to backing data

With `editable: :always`, a user action calls `set_cell_value`. Update backing data there, rather than trying to update the Table directly. Do not retain the received value after the callback.

```crystal
set_cell_value do |row, column, value|
  next unless column == 0
  next unless name = value.try(&.string)

  rows[row] = name
end
```

Replace the `set_cell_value` callback from the previous page with this one.
When this callback handles a user edit, you do not need an extra `row_changed` call. Notify the Model when application code changes a value elsewhere.

For a button-column click, `value` is `nil`; inspect the column and perform the row action. Providing `set_cell_value` even for read-only columns makes the Handler's responsibility explicit.

## Selection and clicks

Use `selection_mode` to control selection. The `Selection` passed to `on_selection_changed` is freed after the callback, so extract `selection.rows` when you need row numbers later.

```crystal
table.selection_mode = UIng::Table::Selection::Mode::ZeroOrOne
table.on_selection_changed do |selection|
  selected_rows = selection.rows
  puts(selected_rows.empty? ? "Nothing selected" : rows[selected_rows.first])
end

table.on_row_double_clicked do |row|
  puts "Double-clicked: #{rows[row]}"
end
```

Header, row-click, and row-double-click events are also available. When sorting, reorder backing data first, then notify the displayed Model of the change.

See [advanced_table.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/advanced_table.cr) for a larger example.
