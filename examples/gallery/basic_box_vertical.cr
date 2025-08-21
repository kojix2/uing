require "../../src/uing"

UIng.init

window = UIng::Window.new("Box Vertical Example", 200, 150, margined: true)
window.on_closing do
  UIng.quit
  true
end

box = UIng::Box.new(:vertical, padded: true)

button1 = UIng::Button.new("Button1") do
  on_clicked do
    UIng.msg_box(window, "Information", "You clicked Button1")
  end
end

button2 = UIng::Button.new("Button2") do
  on_clicked do
    UIng.msg_box(window, "Information", "You clicked Button2")
  end
end

button3 = UIng::Button.new("Button3") do
  on_clicked do
    UIng.msg_box(window, "Information", "You clicked Button3")
  end
end

box.append(button1)
box.append(button2)
box.append(button3)

window.child = box
window.show

UIng.main
UIng.uninit
