require "../../src/uing"

UIng.init

window = UIng::Window.new("EditableCombobox Example", 300, 200, margined: true)
window.on_closing do
  UIng.quit
  true
end

editable_combobox = UIng::EditableCombobox.new(["Item 1", "Item 2", "Item 3"])
editable_combobox.on_changed do |text|
  UIng.msg_box(window, "EditableCombobox Changed", "Text: #{text}")
end

window.child = editable_combobox
window.show

UIng.main
UIng.uninit
