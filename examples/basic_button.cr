require "../src/uing"

UIng.init

window = UIng::Window.new("hello world", 300, 200)
window.on_closing do
  UIng.quit
  true
end

button = UIng::Button.new("Button")
button.on_clicked do
  window.msg_box("Information", "You clicked the button")
end

window.child = button
window.show

UIng.main
UIng.uninit
