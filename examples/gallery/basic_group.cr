require "../../src/uing"

UIng.init

window = UIng::Window.new("Group Example", 300, 200, margined: true)
window.on_closing do
  UIng.quit
  true
end

group = UIng::Group.new("User Settings", margined: true)

box = UIng::Box.new(:vertical, padded: true)

# Enable notifications checkbox
notifications_checkbox = UIng::Checkbox.new("Enable notifications")
notifications_checkbox.checked = true
box.append(notifications_checkbox)

# Theme selection radio buttons
theme_radio = UIng::RadioButtons.new
theme_radio.append("Light")
theme_radio.append("Dark")
theme_radio.append("Auto")
theme_radio.selected = 0
box.append(theme_radio)

# Save button
save_button = UIng::Button.new("Save Settings")
save_button.on_clicked do
  notifications = notifications_checkbox.checked? ? "enabled" : "disabled"
  theme_options = ["Light", "Dark", "Auto"]
  theme = theme_options[theme_radio.selected]
  UIng.msg_box(window, "Settings Saved", "Notifications: #{notifications}\nTheme: #{theme}")
end
box.append(save_button)

group.child = box
window.child = group
window.show

UIng.main
UIng.uninit
