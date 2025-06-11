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
  num_columns do
    2
  end

  column_type do |column|
    UIng::TableValueType::String
  end

  num_rows do
    DATA.size
  end

  cell_value do |row, column|
    UIng::TableValue.new(DATA[row][column])
  end

  set_cell_value do |row, column, value|
    # This example doesn't support editing, so we do nothing
  end
end

table_model = UIng::TableModel.new(model_handler)
table_params = UIng::TableParams.new(table_model)

table = UIng::Table.new(table_params) do
  append_text_column("Animal", 0, -1)
  append_text_column("Description", 1, -1)
end

table.on_selection_changed do |selection|
  if selection.num_rows > 0
    selected_row = selection.rows[0]
    animal = DATA[selected_row][0]
    sound = DATA[selected_row][1]
    puts "Selected: #{animal} says #{sound}"
  else
    puts "No selection"
  end
  # TableSelection is automatically freed after this block
end

table.on_header_clicked do |idx|
  puts "Header clicked: #{idx}"
end

table.on_row_double_clicked do |row|
  animal = DATA[row][0]
  sound = DATA[row][1]
  puts "Double-clicked: #{animal} goes #{sound}!"
end

hbox.append(table, true)
main_window.show

main_window.on_closing do
  puts "Bye Bye"
  # Clean up resources before quitting
  # Note: TableModel should be freed AFTER the table is destroyed
  # The table is automatically destroyed when the window closes
  UIng.quit
  true
end

UIng.main
UIng.uninit
