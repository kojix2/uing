require "../src/libui"

LibUI::LibUI.init(Pointer(LibUI::LibUI::InitOptions).malloc)

w = LibUI::LibUI.new_window("Hello", 300, 200, 1)
LibUI::LibUI.control_show(w)

f = ->(a : Pointer(Void), b : Pointer(Void)) {
  LibUI::LibUI.quit
  1
}
LibUI::LibUI.window_on_closing(w, f, nil)

LibUI::LibUI.main
LibUI::LibUI.uninit
