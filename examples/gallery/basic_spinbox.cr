require "../../src/uing"

UIng.init

window = UIng::Window.new("Spinbox Example", 300, 120, margined: true)
window.on_closing do
  UIng.quit
  true
end

value_label = UIng::Label.new("Value: 42")

spinbox = UIng::Spinbox.new(0, 100, value: 42) do
  on_changed do |v|
    value_label.text = "Value: #{v}"
  end
end

box = UIng::Box.new(:vertical, padded: true)
box.append(value_label)
box.append(spinbox)

window.child = box
window.show

UIng.main
UIng.uninit
