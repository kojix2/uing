require "../src/uing"

UIng.init

Main_window = UIng.new_window("hello world", 300, 200, 1)

button = UIng::Button.new("Button")

button.on_clicked do
  UIng.msg_box(Main_window, "Information", "You clicked the button")
end

UIng.window_on_closing(Main_window) do
  UIng.quit
  1
end

UIng.window_set_child(Main_window, button)
UIng.control_show(Main_window)

UIng.main
UIng.uninit
