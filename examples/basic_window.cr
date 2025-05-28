require "../src/uing"

UIng.init

w = UIng::Window.new("Hello", 300, 200)
w.show

w.on_closing do
  UIng.quit
  1
end

UIng.main
UIng.uninit
