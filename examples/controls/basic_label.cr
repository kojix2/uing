require "../../src/uing"

UIng.init

window = UIng::Window.new("Label Example", 300, 200, margined: true)
window.on_closing do
  UIng.quit
  true
end

label = UIng::Label.new("This is a label.")

window.child = label
window.show

UIng.main
UIng.uninit
