require "../src/uing"

UIng.init

window = UIng::Window.new("hello world", 300, 200)
window.on_closing do
  UIng.quit
  1
end

button = UIng::Button.new("Button") do
  UIng.msg_box(window, "Information", "You clicked the button")
end

window.child = button
window.show

UIng.main
UIng.uninit
