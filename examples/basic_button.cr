require "../src/uing"

UIng.init

window = UIng.new_window("hello world", 300, 200, 1)

button = UIng::Button.new("Button")

button.on_clicked do
  UIng.msg_box(window, "Information", "You clicked the button")
  0
end

window.on_closing do
  UIng.quit
  1
end

window.set_child(button)
window.show

UIng.main
UIng.uninit
