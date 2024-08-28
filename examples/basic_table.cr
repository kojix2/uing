require "../src/uing"

UIng.init

main_window = UIng.new_window("Animal sounds", 300, 200, 1)

hbox = UIng.new_horizontal_box
UIng.window_set_child(main_window, hbox)

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
model_handler.column_type { |_, _, _| UIng::LibUI::TableValueType::String }
model_handler.num_rows { |_, _| 5 }
model_handler.cell_value { |_, _, row, column| UIng.new_table_value_string(DATA[row][column]) }
model_handler.set_cell_value { |_, _, _, _, _| Void }

model = UIng.new_table_model(model_handler)

table_params = UIng::TableParams.new
table_params.model = model
table_params.row_background_color_model_column = -1

table = UIng.new_table(table_params)
UIng.table_append_text_column(table, "Animal", 0, -1, nil)
UIng.table_append_text_column(table, "Description", 1, -1, nil)

UIng.box_append(hbox, table, 1)
UIng.control_show(main_window)

UIng.window_on_closing(main_window) do
  puts "Bye Bye"
  UIng.quit
  1
end

UIng.main
UIng.free_table_model(model)
UIng.uninit
