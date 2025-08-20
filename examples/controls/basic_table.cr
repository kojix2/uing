require "../../src/uing"

UIng.init

main_window = UIng::Window.new("Table Example", 300, 100)

hbox = UIng::Box.new :horizontal
main_window.child = hbox

data = [
  %w[Windows Microsoft],
  %w[macOS Apple],
  %w[Ubuntu Canonical],
]

model_handler = UIng::Table::Model::Handler.new do
  num_columns { 2 }
  column_type { |column| UIng::Table::Value::Type::String }
  num_rows { data.size }
  cell_value { |row, column| UIng::Table::Value.new(data[row][column]) }
  set_cell_value { |row, column, value| }
end

table_model = UIng::Table::Model.new(model_handler)

table = UIng::Table.new(table_model) do
  append_text_column("OS", 0, -1)
  append_text_column("Vendor", 1, -1)
end

hbox.append(table, true)
main_window.show

main_window.on_closing do
  # FIXME: https://github.com/kojix2/uing/issues/6
  hbox.delete(0)
  table.destroy    # Destroy table firs
  table_model.free # Then free model

  UIng.quit
  true
end

UIng.main
UIng.uninit
