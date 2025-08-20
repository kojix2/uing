require "../../src/uing"

UIng.init

window = UIng::Window.new("Slider Example", 300, 100, margined: true)
window.on_closing do
  UIng.quit
  true
end

slider = UIng::Slider.new(0, 100)
slider.on_changed do |v|
  UIng.msg_box(window, "Slider Changed", "Value: #{v}")
end

window.child = slider
window.show

UIng.main
UIng.uninit
