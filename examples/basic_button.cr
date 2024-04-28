require "../src/libui"

LibUI.init(Pointer(LibUI::LibUI::InitOptions).malloc)

Main_window = LibUI.new_window("hello world", 300, 200, 1)

button = LibUI.new_button("Button")

f1 = ->(a : Pointer(Void), b : Pointer(Void)) do
  LibUI.msg_box(Main_window, "Information", "You clicked the button")
end

LibUI.button_on_clicked(button, f1, nil)

f2 = ->(a : Pointer(Void), b : Pointer(Void)) do
  LibUI.quit
  1
end

LibUI.window_on_closing(Main_window, f2, nil)

LibUI.window_set_child(Main_window, button)
LibUI.control_show(Main_window)

LibUI.main
LibUI.uninit
