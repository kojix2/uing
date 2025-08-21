require "../../src/uing"

UIng.init

window = UIng::Window.new("Form Example", 300, 200, margined: true)
window.on_closing do
  UIng.quit
  true
end

form = UIng::Form.new(padded: true)

username_entry = UIng::Entry.new
username_entry.text = "user123"
form.append("Username:", username_entry)

password_entry = UIng::Entry.new(:password)
form.append("Password:", password_entry)

age_spinbox = UIng::Spinbox.new(0, 120)
age_spinbox.value = 25
form.append("Age:", age_spinbox)

volume_slider = UIng::Slider.new(0, 100)
volume_slider.value = 50
form.append("Volume:", volume_slider)

submit_button = UIng::Button.new("Submit")
submit_button.on_clicked do
  username = username_entry.text || ""
  age = age_spinbox.value
  volume = volume_slider.value
  message = "Username: #{username}\nAge: #{age}\nVolume: #{volume}"
  UIng.msg_box(window, "Form Submitted", message)
end
form.append("", submit_button)

window.child = form
window.show

UIng.main
UIng.uninit
