require "../src/libui"

UIng.init

main_window = UIng.new_window("Notepad", 500, 300, 1)
UIng.window_on_closing(main_window) do
  puts "Bye Bye"
  UIng.quit
  1
end

vbox = UIng.new_vertical_box
UIng.window_set_child(main_window, vbox)

entry = UIng.new_non_wrapping_multiline_entry
UIng.box_append(vbox, entry, 1)

UIng.control_show(main_window)
UIng.main
UIng.uninit
