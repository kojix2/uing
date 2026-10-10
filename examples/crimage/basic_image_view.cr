require "../../src/uing/crimage"

fname = File.join(__DIR__, "../gallery/crys.png")
source = CrImage.read(fname)

UIng.init

window = UIng::Window.new("ImageView Example", 300, 200, margined: true)
window.on_closing do
  UIng.quit
  true
end

vbox = UIng::Box.new(:vertical)

image_view = UIng::ImageView.new(source, :fit)

label = UIng::Label.new(fname)

vbox.append(image_view, stretchy: true)
vbox.append(label)

window.child = vbox
window.show

UIng.main
UIng.uninit
