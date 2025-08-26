require "../../src/uing"
require "http/client"
require "stumpy_png"

fname = "#{__DIR__}/crys.png"
canvas = StumpyPNG.read(fname)
width = canvas.width.to_i32
height = canvas.height.to_i32

pixels = Bytes.new(width * height * 4)
(0...height).each do |y|
  (0...width).each do |x|
    offset = (y * width + x) * 4
    r, g, b, a = canvas[x, y].to_rgba
    pixels[offset] = r
    pixels[offset + 1] = g
    pixels[offset + 2] = b
    pixels[offset + 3] = a || 255_u8
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

window.set_child(vbox)
window.show

UIng.main
UIng.uninit
