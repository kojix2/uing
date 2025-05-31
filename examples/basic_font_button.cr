require "../src/uing"

UIng.init

main_window = UIng::Window.new("hello world", 300, 200)

font_button = UIng.new_font_button
font_descriptor = UIng::FontDescriptor.new

font_button.on_changed do |font_descriptor|
  p family: font_descriptor.family,
    size: font_descriptor.size,
    weight: font_descriptor.weight,
    italic: font_descriptor.italic,
    stretch: font_descriptor.stretch
  UIng.free_font_button_font(font_descriptor)
end

main_window.on_closing do
  puts "Bye Bye"
  UIng.quit
  1
end

main_window.set_child(font_button)
main_window.show

UIng.main
UIng.uninit
