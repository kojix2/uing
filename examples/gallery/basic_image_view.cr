require "../../src/uing"
require "crimage"

fname = File.join(__DIR__, "crys.png")
source = CrImage.read(fname)
bounds = source.bounds
width = bounds.width
height = bounds.height

pixels = Bytes.new(width * height * 4)
(0...height).each do |y|
  (0...width).each do |x|
    offset = (y * width + x) * 4
    color = source.at(bounds.min.x + x, bounds.min.y + y).to_rgba8
    pixels[offset] = color.r
    pixels[offset + 1] = color.g
    pixels[offset + 2] = color.b
    pixels[offset + 3] = color.a
  end
end

UIng.init

window = UIng::Window.new("ImageView Example", 300, 200, margined: true)
window.on_closing do
  UIng.quit
  true
end

vbox = UIng::Box.new(:vertical)

image = UIng::Image.new(width, height)
image.append(pixels, width, height, width * 4)
image_view = UIng::ImageView.new(image, :fit)
image.free

label = UIng::Label.new(fname)

vbox.append(image_view, stretchy: true)
vbox.append(label)

window.child = vbox
window.show

UIng.main
UIng.uninit
