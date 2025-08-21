require "../../src/uing"

UIng.init

window = UIng::Window.new("MsgBoxError Examples", 300, 200)
window.on_closing do
  UIng.quit
  true
end
window.show

window.msg_box_error("Error", "An error occurred.")

UIng.main
UIng.uninit
