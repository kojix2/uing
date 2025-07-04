require "../src/uing"

UIng.init

# File menu
UIng::Menu.new("File") do
  append_item("Open").on_clicked do |w|
    puts w.open_file
  end
  append_item("Save").on_clicked do |w|
    puts w.save_file
  end
  append_separator
  should_quit_item = append_check_item("Should Quit_", checked: true)
  append_quit_item

  # onShouldQuit callback is called when the user presses the quit menu item.
  UIng.on_should_quit do
    if should_quit_item.checked?
      puts "Bye Bye (on_should_quit)"
      MAIN_WINDOW.destroy # You have to destroy the window manually.
      true                # UIng.quit is automatically called in the C function onQuitClicked().
    else
      UIng.msg_box(MAIN_WINDOW, "Warning", "Please check \"Should Quit\"")
      false # Don"t quit
    end
  end

  append_preferences_item.on_clicked do
    create_ref_window
  end
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
  append_about_item.on_clicked do |w|
    UIng.msg_box(w, "About", "This is a control gallery example.\nVersion: #{UIng::VERSION}")
  end
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
dp = UIng::DateTimePicker.new(:date) do
  on_changed do |tm|
    puts "DateTimePicker changed: #{tm}"
  end
end
inner.append dp

# Time Picker
tp = UIng::DateTimePicker.new(:time) do
  on_changed do |tm|
    puts "TimePicker changed: #{tm}"
  end
end
inner.append tp

# Date Time Picker
dtp = UIng::DateTimePicker.new do
  on_changed do |tm|
    puts "DateTimePicker changed: #{tm}"
  end
end
inner.append dtp

# Font Button
font_button = UIng::FontButton.new do
  on_changed do |font_descriptor|
    p family: font_descriptor.family,
      size: font_descriptor.size,
      weight: font_descriptor.weight,
      italic: font_descriptor.italic,
      stretch: font_descriptor.stretch
  end
end
inner.append font_button

# Color Button
color_button = UIng::ColorButton.new do
  on_changed do |r, g, b, a|
    puts "Color changed: R=#{r}, G=#{g}, B=#{b}, A=#{a}"
  end
end
inner.append color_button

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
slider.on_changed do |v|
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
cbox.on_selected do |idx|
  puts "New combobox selection: #{idx}"
end

# Editable Combobox
ebox = UIng::EditableCombobox.new ["Editable Item 1", "Editable Item 2", "Editable Item 3"]
inner.append ebox
ebox.on_changed do |text|
  puts "Editable Combobox changed: #{text}"
end

# Radio Buttons
rb = UIng::RadioButtons.new ["Radio Button 1", "Radio Button 2", "Radio Button 3"]
inner.append(rb, true)
rb.on_selected do |idx|
  puts "Radio button selected: index #{idx}"
end

# Tab
tab = UIng::Tab.new
hbox1 = UIng::Box.new(:horizontal)
tab.append("Page 1", hbox1)
tab.append("Page 2", UIng::Box.new(:horizontal))
tab.append("Page 3", UIng::Box.new(:horizontal))
tab.on_selected do |idx|
  puts "Tab selected: index #{idx}"
end
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

MAIN_WINDOW = UIng::Window.new("Control Gallery", 600, 500, menubar: true, margined: true) do
  on_closing do
    puts "Bye Bye"
    UIng.quit
    true
  end
  show
end

def create_ref_window
  UIng::Window.new("Preferences", 300, 200, margined: true) do
    on_closing do
      puts "Preferences window closed"
      true # Allow closing
    end
    set_child(
      UIng::Box.new(:vertical, padded: true) do
        append(label = UIng::Label.new("Preferences"), stretchy: false)
        append(
          UIng::Form.new(padded: true) do
            append("name: ", UIng::Entry.new)
            append("mail: ", UIng::Entry.new)
            append("password: ", UIng::Entry.new(:password))
          end
        )
        append(
          UIng::Grid.new do
            append(UIng::Checkbox.new("Check 1"), 0, 0, 1, 1, true, :fill, true, :fill)
            append(UIng::Checkbox.new("Check 2"), 1, 0, 1, 1, true, :fill, true, :fill)
            append(UIng::Checkbox.new("Check 3"), 0, 1, 1, 1, true, :fill, true, :fill)
            append(UIng::Checkbox.new("Check 4"), 1, 1, 1, 1, true, :fill, true, :fill)
            append(UIng::Checkbox.new("Check 5"), 0, 2, 1, 1, true, :fill, true, :fill)
            append(UIng::Checkbox.new("Check 6"), 1, 2, 1, 1, true, :fill, true, :fill)
          end
        )
        append(
          UIng::Button.new("OK") do
            on_clicked do
              label.text = "Preferences saved"
            end
          end,
          stretchy: false
        )
      end
    )
    show
    x = MAIN_WINDOW.position[0] + MAIN_WINDOW.content_size[0] / 2 - content_size[0] / 2
    y = MAIN_WINDOW.position[1] + MAIN_WINDOW.content_size[1] / 2 - content_size[1] / 2
    set_position(x.to_i, y.to_i)
  end
end

UIng.main
UIng.uninit
