require "../src/libui"

LibUI.init

main_window = LibUI.new_window("Basic Entry", 300, 50, 1)
LibUI.window_on_closing(main_window) do
  puts "Bye Bye"
  LibUI.quit
  1
end

hbox = LibUI.new_horizontal_box
LibUI.window_set_child(main_window, hbox)

entry = LibUI.new_entry
LibUI.entry_on_changed(entry) do
  puts LibUI.entry_text(entry)
end

LibUI.box_append(hbox, entry, 1)

button = LibUI.new_button("Button")
LibUI.button_on_clicked(button) do
  text = LibUI.entry_text(entry)
  LibUI.msg_box(main_window, "You entered", text)
  0
end

LibUI.box_append(hbox, button, 0)

LibUI.control_show(main_window)
LibUI.main
LibUI.uninit
