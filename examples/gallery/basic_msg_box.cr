require "../../src/uing"

UIng.init

window = UIng::Window.new("MsgBox Examples", 300, 200)
window.on_closing do
  UIng.quit
  true
end
window.show

window.msg_box("Message", "Hello Crystal World!")

UIng.main
UIng.uninit
