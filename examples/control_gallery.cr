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
should_quit_item.set_checked(1)
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
MAIN_WINDOW = UIng::Window.new("Control Gallery", 600, 500, 1)
MAIN_WINDOW.set_margined 1
MAIN_WINDOW.on_closing do
  puts "Bye Bye"
  UIng.quit
  # return 1 to destroys the window automatically.
  # return 0 to keep the window. (You can destroy it manually.)
  1
end

vbox = UIng::Box.new(:vertical)
MAIN_WINDOW.set_child(vbox)
hbox = UIng::Box.new(:horizontal)
vbox.set_padded 1
hbox.set_padded 1

vbox.append(hbox, 1)

# Group - Basic Controls
group = UIng::Group.new("Basic Controls")
group.set_margined(1)
hbox.append(group, 1) # OSX bug?

inner = UIng::Box.new(:vertical)
inner.set_padded(1)
group.set_child(inner)

# Button
button = UIng::Button.new("Button")
button.on_clicked do
  UIng.msg_box(MAIN_WINDOW, "Information", "You clicked the button")
end
inner.append(button, 0)

# Checkbox
checkbox = UIng::Checkbox.new("Checkbox")
checkbox.on_toggled do
  checked = (checkbox.checked == 1)
  MAIN_WINDOW.set_title("Checkbox is #{checked}")
  checkbox.set_text("I am the checkbox (#{checked})")
end
inner.append(checkbox, 0)

# Label
inner.append(UIng::Label.new("Label"), 0)

# Separator
inner.append(UIng::Separator.new(:horizontal), 0)

# Date Picker
inner.append(UIng::DateTimePicker.new(:date), 0)

# Time Picker
inner.append(UIng::DateTimePicker.new(:time), 0)

# Date Time Picker
inner.append(UIng::DateTimePicker.new, 0)

# Font Button
inner.append(UIng::FontButton.new, 0)

# Color Button
inner.append(UIng::ColorButton.new, 0)

inner2 = UIng::Box.new(:vertical)
inner2.set_padded(1)
hbox.append(inner2, 1)

# Group - Numbers
group = UIng::Group.new("Numbers")
group.set_margined(1)
inner2.append(group, 0)

inner = UIng::Box.new(:vertical)
inner.set_padded(1)
group.set_child(inner)

# Spinbox
spinbox = UIng::Spinbox.new(0, 100)
spinbox.set_value(42)
spinbox.on_changed do
  puts "New Spinbox value: #{spinbox.value}"
end
inner.append(spinbox, 0)

# Slider
slider = UIng::Slider.new(0, 100)
inner.append(slider, 0)

# Progressbar
progressbar = UIng::ProgressBar.new
inner.append(progressbar, 0)

slider.on_changed do
  v = slider.value
  puts "New Slider value: #{v}"
  progressbar.set_value(v)
end

# Group - Lists
group = UIng::Group.new("Lists")
group.set_margined(1)
inner2.append(group, 0)

inner = UIng::Box.new(:vertical)
inner.set_padded(1)
group.set_child(inner)

# Combobox
cbox = UIng::Combobox.new
cbox.append("combobox Item 1")
cbox.append("combobox Item 2")
cbox.append("combobox Item 3")
inner.append(cbox, 0)
cbox.on_selected do
  puts "New combobox selection: #{cbox.selected}"
end

# Editable Combobox
ebox = UIng::EditableCombobox.new
ebox.append("Editable Item 1")
ebox.append("Editable Item 2")
ebox.append("Editable Item 3")
inner.append(ebox, 0)

# Radio Buttons
rb = UIng::RadioButtons.new
rb.append("Radio Button 1")
rb.append("Radio Button 2")
rb.append("Radio Button 3")
inner.append(rb, 1)

# Tab
tab = UIng::Tab.new
hbox1 = UIng::Box.new(:horizontal)
hbox2 = UIng::Box.new(:horizontal)
tab.append("Page 1", hbox1)
tab.append("Page 2", hbox2)
tab.append("Page 3", UIng::Box.new(:horizontal))
inner2.append(tab, 1)

# Text Entry
text_entry = UIng::Entry.new
text_entry.set_text "Please enter your feelings"
text_entry.on_changed do
  print "Current textbox data: "
  puts text_entry.text
end
hbox1.append(text_entry, 1)

MAIN_WINDOW.show

UIng.main
UIng.uninit
