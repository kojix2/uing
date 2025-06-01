require "../src/uing"

UIng.init

main_window = UIng::Window.new("Animal sounds", 300, 200)

hbox = UIng::Box.new :horizontal
main_window.child = hbox

alias CInt = LibC::Int

DATA = [
  %w[cat meow],
  %w[dog woof],
  %w[chicken cock-a-doodle-doo],
  %w[horse neigh],
  %w[cow moo],
]

model_handler = UIng::TableModelHandler.new do
  num_columns { |_, _| 2 }
  column_type { |_, _, _| UIng::TableValueType::String }
  num_rows { |_, _| 5 }
  cell_value { |_, _, row, column| UIng.new_table_value_string(DATA[row][column]).to_unsafe }
  set_cell_value { |_, _, _, _, _| Void }
end

table_model = UIng::TableModel.new(model_handler)
table_params = UIng::TableParams.new(table_model)

table = UIng::Table.new(table_params) do
  append_text_column("Animal", 0, -1)
  append_text_column("Description", 1, -1)
end

hbox.append(table, true)
main_window.show

main_window.on_closing do
  puts "Bye Bye"
  UIng.quit
  1
end

UIng.main
UIng.free_table_model(table_model)
UIng.uninit
