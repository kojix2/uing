require "../../src/uing"

UIng.init

window = UIng::Window.new("Button Examples", 300, 100, margined: true)
window.on_closing do
  UIng.quit
  true
end

button = UIng::Button.new("Button") do
  on_clicked do
    UIng.msg_box(window, "Information", "You clicked the button")
  end
end

window.child = button
window.show

UIng.main
UIng.uninit
