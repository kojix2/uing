require "../../src/uing"

UIng.init

window = UIng::Window.new("Combobox Example", 300, 200)
window.on_closing do
  UIng.quit
  true
end

combobox = UIng::Combobox.new(["Item 1", "Item 2", "Item 3"])
combobox.on_selected do |idx|
  UIng.msg_box(window, "Combobox Changed", "Selected index: #{idx}")
end

window.child = combobox
window.show

UIng.main
UIng.uninit
