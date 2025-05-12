require "../src/uing"

UIng.init

main_window = UIng::Window.new("Animal sounds", 300, 200, 1)

hbox = UIng::Box.new(:horizontal)
main_window.set_child(hbox)

alias CInt = LibC::Int

DATA = [
  %w[cat meow],
  %w[dog woof],
  %w[chicken cock-a-doodle-doo],
  %w[horse neigh],
  %w[cow moo],
]

model_handler = UIng::TableModelHandler.new
model_handler.num_columns { |_, _| 2 }
model_handler.column_type { |_, _, _| UIng::TableValueType::String }
model_handler.num_rows { |_, _| 5 }
model_handler.cell_value { |_, _, row, column| UIng.new_table_value_string(DATA[row][column]).to_unsafe }
model_handler.set_cell_value { |_, _, _, _, _| Void }

model = UIng::TableModel.new(model_handler)

table_params = UIng::TableParams.new
table_params.model = model
table_params.row_background_color_model_column = -1

table = UIng::Table.new(table_params)
table.append_text_column("Animal", 0, -1, nil)
table.append_text_column("Description", 1, -1, nil)

hbox.append(table, 1)
main_window.show

main_window.on_closing do
  puts "Bye Bye"
  UIng.quit
  1
end

UIng.main
UIng.free_table_model(model)
UIng.uninit
