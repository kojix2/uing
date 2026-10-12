require "../../src/uing"

UIng.init

window = UIng::Window.new("FontButton Example", 300, 100, margined: true)
window.on_closing do
  UIng.quit
  true
end

font_button = UIng::FontButton.new
selected_font = font_button.font
font_button.on_changed do |font_descriptor|
  previous_font = selected_font
  selected_font = font_descriptor
  window.msg_box(
    "Font Changed",
    "Previous: #{previous_font.family}\nFamily: #{selected_font.family}\nSize: #{selected_font.size}"
  )
end

window.child = font_button
window.show

UIng.main
UIng.uninit
