require "../src/uing"

UIng.init

# File menu
menu = UIng.new_menu("File")
open_menu_item = UIng.menu_append_item(menu, "Open")
UIng.menu_item_on_clicked(open_menu_item) do |w|
  pt = UIng.open_file(MAIN_WINDOW)
  puts pt
end
save_menu_item = UIng.menu_append_item(menu, "Save")
UIng.menu_item_on_clicked(save_menu_item) do |w|
  pt = UIng.save_file(MAIN_WINDOW)
  puts pt
end
UIng.menu_append_separator(menu)
should_quit_item = UIng.menu_append_check_item(menu, "Should Quit_")
UIng.menu_item_set_checked(should_quit_item, 1)
UIng.menu_append_quit_item(menu)
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
edit_menu = UIng.new_menu("Edit")
UIng.menu_append_check_item(edit_menu, "Checkable Item_")
UIng.menu_append_separator(edit_menu)
disabled_item = UIng.menu_append_item(edit_menu, "Disabled Item_")
UIng.menu_item_disable(disabled_item)

preferences = UIng.menu_append_preferences_item(menu)

# Help menu
help_menu = UIng.new_menu("Help")
UIng.menu_append_item(help_menu, "Help")
UIng.menu_append_about_item(help_menu)

# Main Window
MAIN_WINDOW = UIng.new_window("Control Gallery", 600, 500, 1)
UIng.window_set_margined(MAIN_WINDOW, 1)
UIng.window_on_closing(MAIN_WINDOW) do
  puts "Bye Bye"
  UIng.quit
  # return 1 to destroys the window automatically.
  # return 0 to keep the window. (You can destroy it manually.)
  1
end

vbox = UIng.new_vertical_box
UIng.window_set_child(MAIN_WINDOW, vbox)
hbox = UIng.new_horizontal_box
UIng.box_set_padded(vbox, 1)
UIng.box_set_padded(hbox, 1)

UIng.box_append(vbox, hbox, 1)

# Group - Basic Controls
group = UIng.new_group("Basic Controls")
UIng.group_set_margined(group, 1)
UIng.box_append(hbox, group, 1) # OSX bug?

inner = UIng.new_vertical_box
UIng.box_set_padded(inner, 1)
UIng.group_set_child(group, inner)

# Button
button = UIng.new_button("Button")
UIng.button_on_clicked(button) do
  UIng.msg_box(MAIN_WINDOW, "Information", "You clicked the button")
end
UIng.box_append(inner, button, 0)

# Checkbox
checkbox = UIng.new_checkbox("Checkbox")
UIng.checkbox_on_toggled(checkbox) do
  checked = UIng.checkbox_checked(checkbox) == 1
  UIng.window_set_title(MAIN_WINDOW, "Checkbox is #{checked}")
  UIng.checkbox_set_text(checkbox, "I am the checkbox (#{checked})")
end
UIng.box_append(inner, checkbox, 0)

# Label
UIng.box_append(inner, UIng.new_label("Label"), 0)

# Separator
UIng.box_append(inner, UIng.new_horizontal_separator, 0)

# Date Picker
UIng.box_append(inner, UIng.new_date_picker, 0)

# Time Picker
UIng.box_append(inner, UIng.new_time_picker, 0)

# Date Time Picker
UIng.box_append(inner, UIng.new_date_time_picker, 0)

# # Font Button
# UIng.box_append(inner, UIng.new_font_button, 0)

# # Color Button
# UIng.box_append(inner, UIng.new_color_button, 0)

inner2 = UIng.new_vertical_box
UIng.box_set_padded(inner2, 1)
UIng.box_append(hbox, inner2, 1)

# Group - Numbers
group = UIng.new_group("Numbers")
UIng.group_set_margined(group, 1)
UIng.box_append(inner2, group, 0)

inner = UIng.new_vertical_box
UIng.box_set_padded(inner, 1)
UIng.group_set_child(group, inner)

# Spinbox
spinbox = UIng.new_spinbox(0, 100)
UIng.spinbox_set_value(spinbox, 42)
UIng.spinbox_on_changed(spinbox) do
  puts "New Spinbox value: #{UIng.spinbox_value(spinbox)}"
end
UIng.box_append(inner, spinbox, 0)

# Slider
slider = UIng.new_slider(0, 100)
UIng.box_append(inner, slider, 0)

# Progressbar
progressbar = UIng.new_progress_bar
UIng.box_append(inner, progressbar, 0)

UIng.slider_on_changed(slider) do
  v = UIng.slider_value(slider)
  puts "New Slider value: #{v}"
  UIng.progress_bar_set_value(progressbar, v)
end

# Group - Lists
group = UIng.new_group("Lists")
UIng.group_set_margined(group, 1)
UIng.box_append(inner2, group, 0)

inner = UIng.new_vertical_box
UIng.box_set_padded(inner, 1)
UIng.group_set_child(group, inner)

# Combobox
cbox = UIng.new_combobox
UIng.combobox_append(cbox, "combobox Item 1")
UIng.combobox_append(cbox, "combobox Item 2")
UIng.combobox_append(cbox, "combobox Item 3")
UIng.box_append(inner, cbox, 0)
UIng.combobox_on_selected(cbox) do
  puts "New combobox selection: #{UIng.combobox_selected(cbox)}"
end

# Editable Combobox
ebox = UIng.new_editable_combobox
UIng.editable_combobox_append(ebox, "Editable Item 1")
UIng.editable_combobox_append(ebox, "Editable Item 2")
UIng.editable_combobox_append(ebox, "Editable Item 3")
UIng.box_append(inner, ebox, 0)

# Radio Buttons
rb = UIng.new_radio_buttons
UIng.radio_buttons_append(rb, "Radio Button 1")
UIng.radio_buttons_append(rb, "Radio Button 2")
UIng.radio_buttons_append(rb, "Radio Button 3")
UIng.box_append(inner, rb, 1)

# Tab
tab = UIng.new_tab
hbox1 = UIng.new_horizontal_box
hbox2 = UIng.new_horizontal_box
UIng.tab_append(tab, "Page 1", hbox1)
UIng.tab_append(tab, "Page 2", hbox2)
UIng.tab_append(tab, "Page 3", UIng.new_horizontal_box)
UIng.box_append(inner2, tab, 1)

# Text Entry
text_entry = UIng.new_entry
UIng.entry_set_text text_entry, "Please enter your feelings"
UIng.entry_on_changed(text_entry) do
  print "Current textbox data: "
  puts UIng.entry_text(text_entry)
end
UIng.box_append(hbox1, text_entry, 1)

UIng.control_show(MAIN_WINDOW)

UIng.main
UIng.uninit
