require "../src/libui"

LibUI::LibUI.init(Pointer(LibUI::LibUI::InitOptions).malloc)

w = LibUI::LibUI.new_window("Hello", 300, 200, 1)
LibUI::LibUI.control_show(w)

LibUI::LibUI.main
LibUI::LibUI.uninit
