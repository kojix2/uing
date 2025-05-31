require "../src/uing"

UIng.init

# File menu
menu = UIng::Menu.new("File")
open_menu_item = menu.append_item("Open")
open_menu_item.on_clicked do |w|
  pt = UIng.open_file(MAIN_WINDOW)
  puts pt
end
save_menu_item = menu.append_item("Save")
save_menu_item.on_clicked do |w|
  pt = UIng.save_file(MAIN_WINDOW)
  puts pt
end
menu.append_separator
should_quit_item = menu.append_check_item("Should Quit_")
should_quit_item.checked = true
menu.append_quit_item
# onShouldQuit callback is called when the user presses the quit menu item.
UIng.on_should_quit do
  if should_quit_item.checked == 1
    puts "Bye Bye (on_should_quit)"
    MAIN_WINDOW.destroy # You have to destroy the window manually.
    1                   # UIng.quit is automatically called in the C function onQuitClicked().
  else
    UIng.msg_box(MAIN_WINDOW, "Warning", "Please check \"Should Quit\"")
    0 # Don"t quit
  end
end

# Edit menu
edit_menu = UIng::Menu.new("Edit")
edit_menu.append_check_item("Checkable Item_")
edit_menu.append_separator
disabled_item = edit_menu.append_item("Disabled Item_")
disabled_item.disable

preferences = menu.append_preferences_item

# Help menu
help_menu = UIng::Menu.new("Help")
help_menu.append_item("Help")
help_menu.append_about_item

# Main Window
MAIN_WINDOW = UIng::Window.new("Control Gallery", 600, 500, true)
MAIN_WINDOW.margined = true
MAIN_WINDOW.on_closing do
  puts "Bye Bye"
  UIng.quit
  # return 1 to destroys the window automatically.
  # return 0 to keep the window. (You can destroy it manually.)
  1
end

vbox = UIng::Box.new(:vertical)
MAIN_WINDOW.child = vbox
hbox = UIng::Box.new(:horizontal)
vbox.padded = true
hbox.padded = true

vbox.append(hbox, true)

# Group - Basic Controls
group = UIng::Group.new("Basic Controls")
group.margined = true
hbox.append(group, true) # OSX bug?

inner = UIng::Box.new(:vertical)
inner.padded = true
group.child = inner

# Button
button = UIng::Button.new("Button") do
  UIng.msg_box(MAIN_WINDOW, "Information", "You clicked the button")
end
inner.append(button, false)

# Checkbox
checkbox = UIng::Checkbox.new("Checkbox")
checkbox.on_toggled do |checked|
  MAIN_WINDOW.title = "Checkbox is #{checked}"
  checkbox.text = "I am the checkbox (#{checked})"
end
inner.append(checkbox, false)

# Label
inner.append(UIng::Label.new("Label"), false)

# Separator
inner.append(UIng::Separator.new(:horizontal), false)

# Date Picker
inner.append(UIng::DateTimePicker.new(:date), false)

# Time Picker
inner.append(UIng::DateTimePicker.new(:time), false)

# Date Time Picker
inner.append(UIng::DateTimePicker.new, false)

# Font Button
inner.append(UIng::FontButton.new, false)

# Color Button
inner.append(UIng::ColorButton.new, false)

inner2 = UIng::Box.new(:vertical)
inner2.padded = true
hbox.append(inner2, true)

# Group - Numbers
group = UIng::Group.new("Numbers")
group.margined = true
inner2.append(group, false)

inner = UIng::Box.new(:vertical)
inner.padded = true
group.child = inner

# Spinbox
spinbox = UIng::Spinbox.new(0, 100)
spinbox.value = 42
spinbox.on_changed do
  puts "New Spinbox value: #{spinbox.value}"
end
inner.append(spinbox, false)

# Slider
slider = UIng::Slider.new(0, 100)
inner.append(slider, false)

# Progressbar
progressbar = UIng::ProgressBar.new
inner.append(progressbar, false)

slider.on_changed do
  v = slider.value
  puts "New Slider value: #{v}"
  progressbar.value = v
end

# Group - Lists
group = UIng::Group.new("Lists")
group.margined = true
inner2.append(group, false)

inner = UIng::Box.new(:vertical)
inner.padded = true
group.child = inner

# Combobox
cbox = UIng::Combobox.new ["Combobox Item 1", "Combobox Item 2", "Combobox Item 3"]
inner.append(cbox, false)
cbox.on_selected do
  puts "New combobox selection: #{cbox.selected}"
end

# Editable Combobox
ebox = UIng::EditableCombobox.new ["Editable Item 1", "Editable Item 2", "Editable Item 3"]
inner.append(ebox, false)

# Radio Buttons
rb = UIng::RadioButtons.new ["Radio Button 1", "Radio Button 2", "Radio Button 3"]
inner.append(rb, true)

# Tab
tab = UIng::Tab.new
hbox1 = UIng::Box.new(:horizontal)
hbox2 = UIng::Box.new(:horizontal)
tab.append("Page 1", hbox1)
tab.append("Page 2", hbox2)
tab.append("Page 3", UIng::Box.new(:horizontal))
inner2.append(tab, true)

# Text Entry
text_entry = UIng::Entry.new
text_entry.text = "Please enter your feelings"
text_entry.on_changed do
  print "Current textbox data: "
  puts text_entry.text
end
hbox1.append(text_entry, true)

MAIN_WINDOW.show

UIng.main
UIng.uninit
