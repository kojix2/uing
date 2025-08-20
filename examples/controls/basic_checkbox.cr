require "../../src/uing"

UIng.init

window = UIng::Window.new("Checkbox Example", 300, 200, margined: true)
window.on_closing do
  UIng.quit
  true
end

checkbox = UIng::Checkbox.new("Check me")
checkbox.on_toggled do |checked|
  UIng.msg_box(window, "Checkbox", "Checked: #{checked}")
end

window.child = checkbox
window.show

UIng.main
UIng.uninit
