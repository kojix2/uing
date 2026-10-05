require "../../src/uing"

UIng.init

main_window = UIng::Window.new("Table Example", 400, 220, margined: true)

vbox = UIng::Box.new(:vertical, padded: true)
main_window.child = vbox

data = [
  %w[Windows Microsoft],
  %w[macOS Apple],
  %w[Ubuntu Canonical],
]

model_handler = UIng::Table::Model::Handler.new do
  num_columns { 2 }
  column_type { |_column| UIng::Table::Value::Type::String }
  num_rows { data.size }
  cell_value { |row, column| UIng::Table::Value.new(data[row][column]) }
  set_cell_value { |_row, _column, _value| }
end

table_model = UIng::Table::Model.new(model_handler)

table = UIng::Table.new(table_model) do
  append_text_column("OS", 0, editable: :never)
  append_text_column("Vendor", 1, editable: :never)
end
table.selection_mode = UIng::Table::Selection::Mode::ZeroOrOne

status = UIng::Label.new("Select a row")
table.on_selection_changed do |selection|
  if selection.num_rows == 0
    status.text = "No row selected"
  else
    row = selection.rows.first
    status.text = "Selected: #{data[row][0]} by #{data[row][1]}"
  end
end

vbox.append(table, true)
vbox.append(status)
main_window.show

main_window.on_closing do
  # Detach and destroy the table before freeing its model.
  vbox.delete(0)
  table.destroy    # Destroy table first
  table_model.free # Then free model

  UIng.quit
  true
end

UIng.main
UIng.uninit
