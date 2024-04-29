require "../src/libui"

LibUI.init

# File menu
menu = LibUI.new_menu("File")
open_menu_item = LibUI.menu_append_item(menu, "Open")
LibUI.menu_item_on_clicked(open_menu_item) do |w|
  pt = LibUI.open_file(MAIN_WINDOW)
  puts pt
end
save_menu_item = LibUI.menu_append_item(menu, "Save")
LibUI.menu_item_on_clicked(save_menu_item) do |w|
  pt = LibUI.save_file(MAIN_WINDOW)
  puts pt
end
LibUI.menu_append_separator(menu)
should_quit_item = LibUI.menu_append_check_item(menu, "Should Quit_")
LibUI.menu_item_set_checked(should_quit_item, 1)
LibUI.menu_append_quit_item(menu)
# onShouldQuit callback is called when the user presses the quit menu item.
LibUI.on_should_quit do
  if LibUI.menu_item_checked(should_quit_item) == 1
    puts "Bye Bye (on_should_quit)"
    LibUI.control_destroy(MAIN_WINDOW) # You have to destroy the window manually.
    1                                  # LibUI.quit is automatically called in the C function onQuitClicked().
  else
    LibUI.msg_box(MAIN_WINDOW, "Warning", "Please check \"Should Quit\"")
    0 # Don"t quit
  end
end

# Edit menu
edit_menu = LibUI.new_menu("Edit")
LibUI.menu_append_check_item(edit_menu, "Checkable Item_")
LibUI.menu_append_separator(edit_menu)
disabled_item = LibUI.menu_append_item(edit_menu, "Disabled Item_")
LibUI.menu_item_disable(disabled_item)

preferences = LibUI.menu_append_preferences_item(menu)

# Help menu
help_menu = LibUI.new_menu("Help")
LibUI.menu_append_item(help_menu, "Help")
LibUI.menu_append_about_item(help_menu)

# Main Window
MAIN_WINDOW = LibUI.new_window("Control Gallery", 600, 500, 1)
LibUI.window_set_margined(MAIN_WINDOW, 1)
LibUI.window_on_closing(MAIN_WINDOW) do
  puts "Bye Bye"
  LibUI.quit
  # return 1 to destroys the window automatically.
  # return 0 to keep the window. (You can destroy it manually.)
  1
end

vbox = LibUI.new_vertical_box
LibUI.window_set_child(MAIN_WINDOW, vbox)
hbox = LibUI.new_horizontal_box
LibUI.box_set_padded(vbox, 1)
LibUI.box_set_padded(hbox, 1)

LibUI.box_append(vbox, hbox, 1)

# Group - Basic Controls
group = LibUI.new_group("Basic Controls")
LibUI.group_set_margined(group, 1)
LibUI.box_append(hbox, group, 1) # OSX bug?

inner = LibUI.new_vertical_box
LibUI.box_set_padded(inner, 1)
LibUI.group_set_child(group, inner)

# Button
button = LibUI.new_button("Button")
LibUI.button_on_clicked(button) do
  LibUI.msg_box(MAIN_WINDOW, "Information", "You clicked the button")
end
LibUI.box_append(inner, button, 0)

# Checkbox
checkbox = LibUI.new_checkbox("Checkbox")
LibUI.checkbox_on_toggled(checkbox) do
  checked = LibUI.checkbox_checked(checkbox) == 1
  LibUI.window_set_title(MAIN_WINDOW, "Checkbox is #{checked}")
  LibUI.checkbox_set_text(checkbox, "I am the checkbox (#{checked})")
end
LibUI.box_append(inner, checkbox, 0)

# Label
LibUI.box_append(inner, LibUI.new_label("Label"), 0)

# Separator
LibUI.box_append(inner, LibUI.new_horizontal_separator, 0)

# Date Picker
LibUI.box_append(inner, LibUI.new_date_picker, 0)

# Time Picker
LibUI.box_append(inner, LibUI.new_time_picker, 0)

# Date Time Picker
LibUI.box_append(inner, LibUI.new_date_time_picker, 0)

# Font Button
LibUI.box_append(inner, LibUI.new_font_button, 0)

# Color Button
LibUI.box_append(inner, LibUI.new_color_button, 0)

inner2 = LibUI.new_vertical_box
LibUI.box_set_padded(inner2, 1)
LibUI.box_append(hbox, inner2, 1)

# Group - Numbers
group = LibUI.new_group("Numbers")
LibUI.group_set_margined(group, 1)
LibUI.box_append(inner2, group, 0)

inner = LibUI.new_vertical_box
LibUI.box_set_padded(inner, 1)
LibUI.group_set_child(group, inner)

# Spinbox
spinbox = LibUI.new_spinbox(0, 100)
LibUI.spinbox_set_value(spinbox, 42)
LibUI.spinbox_on_changed(spinbox) do
  puts "New Spinbox value: #{LibUI.spinbox_value(spinbox)}"
end
LibUI.box_append(inner, spinbox, 0)

# Slider
slider = LibUI.new_slider(0, 100)
LibUI.box_append(inner, slider, 0)

# Progressbar
progressbar = LibUI.new_progress_bar
LibUI.box_append(inner, progressbar, 0)

LibUI.slider_on_changed(slider) do
  v = LibUI.slider_value(slider)
  puts "New Slider value: #{v}"
  LibUI.progress_bar_set_value(progressbar, v)
end

# Group - Lists
group = LibUI.new_group("Lists")
LibUI.group_set_margined(group, 1)
LibUI.box_append(inner2, group, 0)

inner = LibUI.new_vertical_box
LibUI.box_set_padded(inner, 1)
LibUI.group_set_child(group, inner)

# Combobox
cbox = LibUI.new_combobox
LibUI.combobox_append(cbox, "combobox Item 1")
LibUI.combobox_append(cbox, "combobox Item 2")
LibUI.combobox_append(cbox, "combobox Item 3")
LibUI.box_append(inner, cbox, 0)
LibUI.combobox_on_selected(cbox) do
  puts "New combobox selection: #{LibUI.combobox_selected(cbox)}"
end

# Editable Combobox
ebox = LibUI.new_editable_combobox
LibUI.editable_combobox_append(ebox, "Editable Item 1")
LibUI.editable_combobox_append(ebox, "Editable Item 2")
LibUI.editable_combobox_append(ebox, "Editable Item 3")
LibUI.box_append(inner, ebox, 0)

# Radio Buttons
rb = LibUI.new_radio_buttons
LibUI.radio_buttons_append(rb, "Radio Button 1")
LibUI.radio_buttons_append(rb, "Radio Button 2")
LibUI.radio_buttons_append(rb, "Radio Button 3")
LibUI.box_append(inner, rb, 1)

# Tab
tab = LibUI.new_tab
hbox1 = LibUI.new_horizontal_box
hbox2 = LibUI.new_horizontal_box
LibUI.tab_append(tab, "Page 1", hbox1)
LibUI.tab_append(tab, "Page 2", hbox2)
LibUI.tab_append(tab, "Page 3", LibUI.new_horizontal_box)
LibUI.box_append(inner2, tab, 1)

# Text Entry
text_entry = LibUI.new_entry
LibUI.entry_set_text text_entry, "Please enter your feelings"
LibUI.entry_on_changed(text_entry) do
  print "Current textbox data: "
  puts LibUI.entry_text(text_entry)
end
LibUI.box_append(hbox1, text_entry, 1)

LibUI.control_show(MAIN_WINDOW)

LibUI.main
LibUI.uninit
