require "../../src/uing"

UIng.init

window = UIng::Window.new("Separator Example", 360, 160, margined: true)
window.on_closing do
  UIng.quit
  true
end

box = UIng::Box.new(:vertical, padded: true)
box.append(UIng::Label.new("Above the separator"), stretchy: false)
box.append(UIng::Separator.new(:horizontal), stretchy: false)

row = UIng::Box.new(:horizontal, padded: true)
row.append(UIng::Label.new("Left of the separator"))
row.append(UIng::Separator.new(:vertical), stretchy: false)
row.append(UIng::Label.new("Right of the separator"))
box.append(row)

window.child = box
window.show

UIng.main
UIng.uninit
