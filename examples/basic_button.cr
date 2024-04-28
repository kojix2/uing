require "../src/libui"

LibUI.init

Main_window = LibUI.new_window("hello world", 300, 200, 1)

button = LibUI.new_button("Button")

LibUI.button_on_clicked(button) do
  LibUI.msg_box(Main_window, "Information", "You clicked the button")
end

LibUI.window_on_closing(Main_window) do
  LibUI.quit
  1
end

LibUI.window_set_child(Main_window, button)
LibUI.control_show(Main_window)

LibUI.main
LibUI.uninit
