require "../src/libui"

LibUI.init

main_window = LibUI.new_window("hello world", 300, 200, 1)

font_button = LibUI.new_font_button
font_descriptor = LibUI::FontDescriptor.new

LibUI.font_button_on_changed(font_button) do
  LibUI.font_button_font(font_button, font_descriptor)
  p family: font_descriptor.family,
    size: font_descriptor.size,
    weight: font_descriptor.weight,
    italic: font_descriptor.italic,
    stretch: font_descriptor.stretch
end

LibUI.window_on_closing(main_window) do
  puts "Bye Bye"
  LibUI.quit
  1
end

LibUI.window_set_child(main_window, font_button)
LibUI.control_show(main_window)

LibUI.main
LibUI.uninit
