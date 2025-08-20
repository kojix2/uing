require "../../src/uing"

UIng.init

window = UIng::Window.new("ColorButton Example", 300, 200, margined: true)
window.on_closing do
  UIng.quit
  true
end

color_button = UIng::ColorButton.new do
  on_changed do |r, g, b, a|
    UIng.msg_box(window, "Color Changed", "R=#{r}, G=#{g}, B=#{b}, A=#{a}")
  end
end

window.child = color_button
window.show

UIng.main
UIng.uninit
