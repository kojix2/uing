require "../src/libui"

LibUI.init

w = LibUI.new_window("Hello", 300, 200, 1)
LibUI.control_show(w)

LibUI.window_on_closing(w) do
  LibUI.quit
  1
end

LibUI.main
LibUI.uninit
