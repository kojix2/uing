require "../src/libui"

UIng.init

w = UIng.new_window("Hello", 300, 200, 1)
UIng.control_show(w)

UIng.window_on_closing(w) do
  UIng.quit
  1
end

UIng.main
UIng.uninit
