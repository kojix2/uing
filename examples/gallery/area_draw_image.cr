require "../../src/uing"
require "stumpy_png"

fname = File.join(__DIR__, "crys.png")
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

image = UIng::Image.new(width, height)
image.append(pixels, width, height, width * 4)

window = UIng::Window.new("Draw Image Example", 400, 400, margined: true)
window.on_closing do
  UIng.quit
  true
end

area_handler = UIng::Area::Handler.new do |header|
  draw do |area, params|
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
window.set_child(box)
window.show

UIng.main

image.free
UIng.uninit
