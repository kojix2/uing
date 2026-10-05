require "../../src/uing"

UIng.init

window = UIng::Window.new("File Dialog Example", 420, 180, margined: true)
window.on_closing do
  UIng.quit
  true
end

status = UIng::Label.new("Choose an operation")

open_file_button = UIng::Button.new("Open file")
open_file_button.on_clicked do
  status.text = if path = window.open_file
                  "Selected file: #{path}"
                else
                  "Open file canceled"
                end
end

open_folder_button = UIng::Button.new("Open folder")
open_folder_button.on_clicked do
  status.text = if path = window.open_folder
                  "Selected folder: #{path}"
                else
                  "Open folder canceled"
                end
end

save_file_button = UIng::Button.new("Save file")
save_file_button.on_clicked do
  status.text = if path = window.save_file
                  "Save to: #{path}"
                else
                  "Save file canceled"
                end
end

buttons = UIng::Box.new(:horizontal, padded: true)
buttons.append(open_file_button)
buttons.append(open_folder_button)
buttons.append(save_file_button)

box = UIng::Box.new(:vertical, padded: true)
box.append(UIng::Label.new("Native file and folder dialogs"))
box.append(buttons)
box.append(status)

window.child = box
window.show

UIng.main
UIng.uninit
