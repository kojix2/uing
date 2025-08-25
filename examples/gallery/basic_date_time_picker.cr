require "../../src/uing"

UIng.init

window = UIng::Window.new("DateTimePicker Example", 300, 100, margined: true)
window.on_closing do
  UIng.quit
  true
end

date_picker = UIng::DateTimePicker.new(:date) do
  on_changed do |tm|
    window.msg_box("Date Changed", tm.to_s)
  end
end

window.child = date_picker
window.show

UIng.main
UIng.uninit
