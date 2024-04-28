require "../src/libui"

LibUI.init

main_window = LibUI.new_window("Notepad", 500, 300, 1)
LibUI.window_on_closing(main_window) do
  puts "Bye Bye"
  LibUI.quit
  1
end

vbox = LibUI.new_vertical_box
LibUI.window_set_child(main_window, vbox)

entry = LibUI.new_non_wrapping_multiline_entry
LibUI.box_append(vbox, entry, 1)

LibUI.control_show(main_window)
LibUI.main
LibUI.uninit
