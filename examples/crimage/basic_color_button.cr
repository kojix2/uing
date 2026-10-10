require "../../src/uing/crimage"

UIng.init

window = UIng::Window.new("ColorButton Example", 300, 100, margined: true)
window.on_closing do
  UIng.quit
  true
end

color_button = UIng::ColorButton.new do |button|
  button.color = CrImage::Color::NRGBA.new(255, 0, 0, 255)
  on_changed do |red, green, blue, alpha|
    window.msg_box("Color Changed", "R=#{red}, G=#{green}, B=#{blue}, A=#{alpha}")
  end
end

window.child = color_button
window.show

UIng.main
UIng.uninit
