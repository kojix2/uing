require "../../src/uing"

UIng.init

window = UIng::Window.new("File Dialog Example", 620, 360, margined: true)
window.on_closing do
  UIng.quit
  true
end

status = UIng::Label.new("Choose an operation")
paths_display = UIng::MultilineEntry.new(wrapping: false, read_only: true)

open_file_button = UIng::Button.new("Open file")
open_file_button.on_clicked do
  status.text = if path = window.open_file
                  paths_display.text = path
                  "Selected 1 file"
                else
                  paths_display.text = ""
                  "Open file canceled"
                end
end

open_files_button = UIng::Button.new("Open files")
open_files_button.on_clicked do
  status.text = if paths = window.open_files
                  paths_display.text = paths.join("\n")
                  "Selected #{paths.size} files"
                else
                  paths_display.text = ""
                  "Open files canceled"
                end
end

open_folder_button = UIng::Button.new("Open folder")
open_folder_button.on_clicked do
  status.text = if path = window.open_folder
                  paths_display.text = path
                  "Selected 1 folder"
                else
                  paths_display.text = ""
                  "Open folder canceled"
                end
end

open_folders_button = UIng::Button.new("Open folders")
open_folders_button.on_clicked do
  status.text = if paths = window.open_folders
                  paths_display.text = paths.join("\n")
                  "Selected #{paths.size} folders"
                else
                  paths_display.text = ""
                  "Open folders canceled"
                end
end

save_file_button = UIng::Button.new("Save file")
save_file_button.on_clicked do
  status.text = if path = window.save_file
                  paths_display.text = path
                  "Selected save path"
                else
                  paths_display.text = ""
                  "Save file canceled"
                end
end

buttons = UIng::Box.new(:horizontal, padded: true)
buttons.append(open_file_button)
buttons.append(open_files_button)
buttons.append(open_folder_button)
buttons.append(open_folders_button)
buttons.append(save_file_button)

box = UIng::Box.new(:vertical, padded: true)
box.append(UIng::Label.new("Native file and folder dialogs"))
box.append(buttons)
box.append(status)
box.append(paths_display, stretchy: true)

window.child = box
window.show

UIng.main
UIng.uninit
