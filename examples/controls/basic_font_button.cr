require "../../src/uing"

UIng.init

window = UIng::Window.new("FontButton Example", 300, 200, margined: true)
window.on_closing do
  UIng.quit
  true
end

font_button = UIng::FontButton.new do
  on_changed do |font_descriptor|
    UIng.msg_box(window, "Font Changed", "Family: #{font_descriptor.family}\nSize: #{font_descriptor.size}")
  end
end

window.child = font_button
window.show

UIng.main
UIng.uninit
