require "../../src/uing"

UIng.init

window = UIng::Window.new("Entry Example", 300, 200)
window.on_closing do
  UIng.quit
  true
end

entry = UIng::Entry.new
entry.text = "Type here"
entry.on_changed do
  UIng.msg_box(window, "Entry Changed", "Text: #{entry.text}")
end

window.child = entry
window.show

UIng.main
UIng.uninit
