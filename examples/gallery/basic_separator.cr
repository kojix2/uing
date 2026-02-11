require "../../src/uing"

UIng.init

window = UIng::Window.new("Separator Example", 300, 100, margined: true)
window.on_closing do
  UIng.quit
  true
end

separator = UIng::Separator.new(:horizontal)

window.child = separator
window.show

UIng.main
UIng.uninit
