require "../../src/uing"

UIng.init

window = UIng::Window.new("DateTimePicker Example", 300, 200, margined: true)
window.on_closing do
  UIng.quit
  true
end

date_picker = UIng::DateTimePicker.new(:date) do
  on_changed do |tm|
    UIng.msg_box(window, "Date Changed", tm.to_s)
  end
end

window.child = date_picker
window.show

UIng.main
UIng.uninit
