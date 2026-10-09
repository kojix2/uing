# Table

[日本語](../guide_ja/widget-table.html)

Table presents model-backed rows and native text, image, checkbox, progress, and button columns.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-ubuntu.png" alt="Table on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-windows.png" alt="Table on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-macos.png" alt="Table on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_table" %}}

## Basic setup

`Table::Model::Handler` supplies data, which a `Table` displays through a `Table::Model`. See the runnable example above for initialization and window creation.

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

Row and model column indices start at zero. The `0` in `append_text_column` selects the model column to display. Model column counts and types are fixed at creation; cell values must match their column types.

## In this chapter

This page covers the smallest useful setup. The following pages build on it with model callbacks and value ownership, columns/editing/selection, and data updates with destruction order.

- [Models and data](table-model.html): the Model and Handler roles, types, and `Table::Value` ownership
- [Columns, editing, and selection](table-columns.html): adding columns, editable cells, selection, and click events
- [Updates and lifetime](table-updates-and-lifetime.html): row notifications and safe cleanup

## Related examples

<div class="widget-screenshots">
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/csv_viewer.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/csv_viewer-ubuntu.png" alt="CSV viewer" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/csv_viewer.cr">CSV viewer</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/advanced_table.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/advanced_table-ubuntu.png" alt="Advanced Table" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/advanced_table.cr">Advanced Table</a></figcaption></figure>
</div>

[API reference](../../api/UIng/Table.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_table.cr)
