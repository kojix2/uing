require "../src/libui"

UIng.init

main_window = UIng.new_window("Basic Entry", 300, 50, 1)
UIng.window_on_closing(main_window) do
  puts "Bye Bye"
  UIng.quit
  1
end

hbox = UIng.new_horizontal_box
UIng.window_set_child(main_window, hbox)

entry = UIng.new_entry
UIng.entry_on_changed(entry) do
  puts UIng.entry_text(entry)
end

UIng.box_append(hbox, entry, 1)

button = UIng.new_button("Button")
UIng.button_on_clicked(button) do
  text = UIng.entry_text(entry)
  UIng.msg_box(main_window, "You entered", text)
  0
end

UIng.box_append(hbox, button, 0)

UIng.control_show(main_window)
UIng.main
UIng.uninit
