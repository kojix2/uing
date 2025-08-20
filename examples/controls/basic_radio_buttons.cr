require "../../src/uing"

UIng.init

window = UIng::Window.new("RadioButtons Example", 300, 200, margined: true)
window.on_closing do
  UIng.quit
  true
end

radio_buttons = UIng::RadioButtons.new(["Option 1", "Option 2", "Option 3"])
radio_buttons.on_selected do |idx|
  UIng.msg_box(window, "RadioButtons Changed", "Selected index: #{idx}")
end

window.child = radio_buttons
window.show

UIng.main
UIng.uninit
