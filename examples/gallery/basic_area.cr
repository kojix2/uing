require "../../src/uing"

UIng.init

window = UIng::Window.new("Area Example", 300, 100)
window.on_closing do
  UIng.quit
  true
end

handler = UIng::Area::Handler.new
handler.draw do |area, params|
  brush = UIng::Area::Draw::Brush.new(:solid, 0.4, 0.4, 0.8, 1.0)
  params.context.fill_path(brush) do |path|
    path.add_rectangle(0, 0, 100, 100)
  end
  brush = UIng::Area::Draw::Brush.new(:solid, 0.8, 0.2, 0.2, 1.0)
  params.context.fill_path(brush) do |path|
    path.add_rectangle(25, 25, 50, 50)
  end
end

area = UIng::Area.new(handler)
box = UIng::Box.new(:vertical, padded: true)
box.append(area, stretchy: true)
window.child = box

window.show

UIng.main
UIng.uninit
