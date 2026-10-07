require "../../src/uing"
require "crimage"

fname = File.join(__DIR__, "crys.png")
source = CrImage.read(fname)
bounds = source.bounds
width = bounds.width
height = bounds.height

# CrImage::Color#to_rgba8 returns premultiplied RGBA as required by UIng::Image.
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

image = UIng::Image.new(width, height)
image.append(pixels, width, height, width * 4)

window = UIng::Window.new("Draw Image Example", 400, 400, margined: true)
window.on_closing do
  UIng.quit
  true
end

area_handler = UIng::Area::Handler.new do |_handler|
  draw do |_area, params|
    ctx = params.context
    white_brush = UIng::Area::Draw::Brush.new(:solid, 1.0, 1.0, 1.0, 1.0)
    ctx.fill_path(white_brush) do |path|
      path.add_rectangle(0, 0, params.area_width, params.area_height)
    end
    begin
      ctx.draw_image(image, 10, 10, 100, 100)
      ctx.draw_image(image, 160, 10, 200, 100)
      ctx.draw_image(image, 10, 160, 100, 200)
      ctx.draw_image(image, 160, 160, 200, 200)
    rescue ex
      UIng.handle_callback_error(ex, "draw_image")
    end
  end
end

area = UIng::Area.new(area_handler)
box = UIng::Box.new(:horizontal)
box.append(area, stretchy: true)
window.child = box
window.show

UIng.main

image.free
UIng.uninit
