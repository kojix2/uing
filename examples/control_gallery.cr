require "../src/uing"

UIng.init

# File menu
UIng::Menu.new("File") do
  append_item("Open").on_clicked do |w|
    pt = UIng.open_file(MAIN_WINDOW)
    puts pt
  end
  append_item("Save").on_clicked do |w|
    pt = UIng.save_file(MAIN_WINDOW)
    puts pt
  end
  append_separator
  should_quit_item = append_check_item("Should Quit_", checked: true)
  append_quit_item

  # onShouldQuit callback is called when the user presses the quit menu item.
  UIng.on_should_quit do
    if should_quit_item.checked
      puts "Bye Bye (on_should_quit)"
      MAIN_WINDOW.destroy # You have to destroy the window manually.
      true                # UIng.quit is automatically called in the C function onQuitClicked().
    else
      UIng.msg_box(MAIN_WINDOW, "Warning", "Please check \"Should Quit\"")
      false # Don"t quit
    end
  end

  append_preferences_item
end

# Edit menu
UIng::Menu.new("Edit") do
  append_check_item("Checkable Item_")
  append_separator
  disabled_item = append_item("Disabled Item_")
  disabled_item.disable
end

# Help menu
UIng::Menu.new("Help") do
  append_item("Help")
  append_about_item
end

vbox = UIng::Box.new(:vertical, padded: true)
MAIN_WINDOW.child = vbox
hbox = UIng::Box.new(:horizontal, padded: true)

vbox.append(hbox, stretchy: true)

# Group - Basic Controls
group = UIng::Group.new("Basic Controls", margined: true)
hbox.append(group, stretchy: true)

inner = UIng::Box.new(:vertical, padded: true)
group.child = inner

# Button
button = UIng::Button.new("Button") do
  on_clicked do
    UIng.msg_box(MAIN_WINDOW, "Information", "You clicked the button")
  end
end
inner.append(button, false)

# Checkbox
checkbox = UIng::Checkbox.new("Checkbox")
checkbox.on_toggled do |checked|
  MAIN_WINDOW.title = "Checkbox is #{checked}"
  checkbox.text = "I am the checkbox (#{checked})"
end
inner.append checkbox

# Label
inner.append UIng::Label.new("Label")

# Separator
inner.append UIng::Separator.new(:horizontal)

# Date Picker
inner.append UIng::DateTimePicker.new(:date)

# Time Picker
inner.append UIng::DateTimePicker.new(:time)

# Date Time Picker
inner.append UIng::DateTimePicker.new

# Font Button
inner.append UIng::FontButton.new

# Color Button
inner.append UIng::ColorButton.new

inner2 = UIng::Box.new(:vertical, padded: true)
hbox.append(inner2, true)

# Group - Numbers
group = UIng::Group.new("Numbers", margined: true)
inner2.append group

inner = UIng::Box.new(:vertical, padded: true)
group.child = inner

# Spinbox
spinbox = UIng::Spinbox.new(0, 100, value: 42) do
  on_changed { |v| puts "New Spinbox value: #{v}" }
end
inner.append spinbox

# Slider
slider = UIng::Slider.new(0, 100)
inner.append slider

# Progressbar
progressbar = UIng::ProgressBar.new
inner.append progressbar

# FIXME
slider.on_changed do
  v = slider.value
  puts "New Slider value: #{v}"
  progressbar.value = v
end

# Group - Lists
group = UIng::Group.new("Lists", margined: true)
inner2.append group

inner = UIng::Box.new(:vertical, padded: true)
group.child = inner

# Combobox
cbox = UIng::Combobox.new ["Combobox Item 1", "Combobox Item 2", "Combobox Item 3"]
inner.append cbox
cbox.on_selected do
  puts "New combobox selection: #{cbox.selected}"
end

# Editable Combobox
ebox = UIng::EditableCombobox.new ["Editable Item 1", "Editable Item 2", "Editable Item 3"]
inner.append ebox

# Radio Buttons
rb = UIng::RadioButtons.new ["Radio Button 1", "Radio Button 2", "Radio Button 3"]
inner.append(rb, true)

# Tab
tab = UIng::Tab.new
hbox1 = UIng::Box.new(:horizontal)
tab.append("Page 1", hbox1)
tab.append("Page 2", UIng::Box.new(:horizontal))
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
# Main Window

MAIN_WINDOW = UIng::Window.new("Control Gallery", 600, 500, true) do
  margined = true
  on_closing do
    puts "Bye Bye"
    UIng.quit
    true
  end
  show
end

UIng.main
UIng.uninit
