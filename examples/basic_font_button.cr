require "../src/uing"

UIng.init

main_window = UIng.new_window("hello world", 300, 200, 1)

font_button = UIng.new_font_button
font_descriptor = UIng::FontDescriptor.new

UIng.font_button_on_changed(font_button) do
  UIng.font_button_font(font_button, font_descriptor)
  p family: font_descriptor.family,
    size: font_descriptor.size,
    weight: font_descriptor.weight,
    italic: font_descriptor.italic,
    stretch: font_descriptor.stretch
end

UIng.window_on_closing(main_window) do
  puts "Bye Bye"
  UIng.quit
  1
end

UIng.window_set_child(main_window, font_button)
UIng.control_show(main_window)

UIng.main
UIng.uninit
