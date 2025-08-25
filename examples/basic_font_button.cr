require "../src/uing"

UIng.init

main_window = UIng::Window.new("hello world", 300, 200)

font_button = UIng::FontButton.new
font_descriptor = UIng::FontDescriptor.new

font_button.on_changed do |font_descriptor|
  p family: font_descriptor.family,
    size: font_descriptor.size,
    weight: font_descriptor.weight,
    italic: font_descriptor.italic,
    stretch: font_descriptor.stretch
  # font_descriptor.free is called automatically in the on_changed callback
end

main_window.on_closing do
  puts "Bye Bye"
  UIng.quit
  true
end

main_window.set_child(font_button)
main_window.show

UIng.main
UIng.uninit
