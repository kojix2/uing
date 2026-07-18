require "../../src/uing"

UIng.init

window = UIng::Window.new("Window Example", 300, 100, margined: true)
window.on_closing do
  UIng.quit
  true
end

window.show

UIng.main
UIng.uninit
