require "../src/uing"

UIng.init

# File menu
menu = UIng::Menu.new("File")
open_menu_item = menu.append_item("Open")
UIng.menu_item_on_clicked(open_menu_item) do |w|
  pt = UIng.open_file(MAIN_WINDOW)
  puts pt
end
save_menu_item = menu.append_item("Save")
UIng.menu_item_on_clicked(save_menu_item) do |w|
  pt = UIng.save_file(MAIN_WINDOW)
  puts pt
end
menu.append_separator
should_quit_item = menu.append_check_item("Should Quit_")
should_quit_item.set_checked(1)
menu.append_quit_item
# onShouldQuit callback is called when the user presses the quit menu item.
UIng.on_should_quit do
  if UIng.menu_item_checked(should_quit_item) == 1
    puts "Bye Bye (on_should_quit)"
    UIng.control_destroy(MAIN_WINDOW) # You have to destroy the window manually.
    1                                 # UIng.quit is automatically called in the C function onQuitClicked().
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

preferences = UIng.menu_append_preferences_item(menu)

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

inner = UIng.new_vertical_box
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
  checked = UIng.checkbox_checked(checkbox) == 1
  UIng.window_set_title(MAIN_WINDOW, "Checkbox is #{checked}")
  UIng.checkbox_set_text(checkbox, "I am the checkbox (#{checked})")
end
inner.append(checkbox, 0)

# Label
inner.append(UIng.new_label("Label"), 0)

# Separator
inner.append(UIng.new_horizontal_separator, 0)

# Date Picker
inner.append(UIng.new_date_picker, 0)

# Time Picker
inner.append(UIng.new_time_picker, 0)

# Date Time Picker
inner.append(UIng.new_date_time_picker, 0)

# Font Button
inner.append(UIng.new_font_button, 0)

# Color Button
inner.append(UIng.new_color_button, 0)

inner2 = UIng.new_vertical_box
inner2.set_padded(1)
hbox.append(inner2, 1)

# Group - Numbers
group = UIng::Group.new("Numbers")
group.set_margined(1)
inner2.append(group, 0)

inner = UIng.new_vertical_box
inner.set_padded(1)
group.set_child(inner)

# Spinbox
spinbox = UIng.new_spinbox(0, 100)
UIng.spinbox_set_value(spinbox, 42)
UIng.spinbox_on_changed(spinbox) do
  puts "New Spinbox value: #{UIng.spinbox_value(spinbox)}"
end
inner.append(spinbox, 0)

# Slider
slider = UIng.new_slider(0, 100)
inner.append(slider, 0)

# Progressbar
progressbar = UIng.new_progress_bar
inner.append(progressbar, 0)

UIng.slider_on_changed(slider) do
  v = UIng.slider_value(slider)
  puts "New Slider value: #{v}"
  UIng.progress_bar_set_value(progressbar, v)
end

# Group - Lists
group = UIng::Group.new("Lists")
group.set_margined(1)
inner2.append(group, 0)

inner = UIng.new_vertical_box
inner.set_padded(1)
group.set_child(inner)

# Combobox
cbox = UIng.new_combobox
cbox.append("combobox Item 1")
cbox.append("combobox Item 2")
cbox.append("combobox Item 3")
inner.append(cbox, 0)
cbox.on_selected do
  puts "New combobox selection: #{UIng.combobox_selected(cbox)}"
end

# Editable Combobox
ebox = UIng.new_editable_combobox
ebox.append("Editable Item 1")
ebox.append("Editable Item 2")
ebox.append("Editable Item 3")
inner.append(ebox, 0)

# Radio Buttons
rb = UIng.new_radio_buttons
rb.append("Radio Button 1")
rb.append("Radio Button 2")
rb.append("Radio Button 3")
inner.append(rb, 1)

# Tab
tab = UIng.new_tab
hbox1 = UIng::Box.new(:horizontal)
hbox2 = UIng::Box.new(:horizontal)
tab.append("Page 1", hbox1)
tab.append("Page 2", hbox2)
tab.append("Page 3", UIng::Box.new(:horizontal))
inner2.append(tab, 1)

# Text Entry
text_entry = UIng.new_entry
UIng.entry_set_text text_entry, "Please enter your feelings"
UIng.entry_on_changed(text_entry) do
  print "Current textbox data: "
  puts UIng.entry_text(text_entry)
end
hbox1.append(text_entry, 1)

UIng.control_show(MAIN_WINDOW)

UIng.main
UIng.uninit
