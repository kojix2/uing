require "../../src/uing/crimage"

fname = File.join(__DIR__, "../gallery/crys.png")
source = CrImage.read(fname)

UIng.init

image = source.to_uing_image

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
