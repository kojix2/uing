require "../../src/uing"

UIng.init

window = UIng::Window.new("Slider Example", 320, 120, margined: true)
window.on_closing do
  UIng.quit
  true
end

value_label = UIng::Label.new("Value: 42")

slider = UIng::Slider.new(0, 100, 42)
slider.has_tool_tip = true
slider.on_changed do |v|
  value_label.text = "Value: #{v}"
end

box = UIng::Box.new(:vertical, padded: true)
box.append(value_label)
box.append(slider)

window.child = box
window.show

UIng.main
UIng.uninit
