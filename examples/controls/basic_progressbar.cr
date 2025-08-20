require "../../src/uing"

UIng.init

window = UIng::Window.new("ProgressBar Example", 300, 200)
window.on_closing do
  UIng.quit
  true
end

progressbar = UIng::ProgressBar.new

window.child = progressbar
window.show

UIng.main
UIng.uninit
