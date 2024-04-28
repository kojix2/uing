require "../src/libui"

LibUI.init(Pointer(LibUI::LibUI::InitOptions).malloc)

w = LibUI.new_window("Hello", 300, 200, 1)
LibUI.control_show(w)

f = ->(a : Pointer(Void), b : Pointer(Void)) {
  LibUI.quit
  1
}
LibUI.window_on_closing(w, f, nil)

LibUI.main
LibUI.uninit
