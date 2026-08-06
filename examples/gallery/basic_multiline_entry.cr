require "../../src/uing"

UIng.init

window = UIng::Window.new("MultilineEntry Example", 300, 100, margined: true)
window.on_closing do
  UIng.quit
  true
end

multiline_entry = UIng::MultilineEntry.new
multiline_entry.text = "Type here\nThis is a multiline entry."

window.child = multiline_entry
window.show

UIng.main
UIng.uninit
