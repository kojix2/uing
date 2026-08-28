require "../../src/uing"
require "base64"
require "compress/zlib"

class ControlGalleryApp
  NEW_ICON = "eNpjYKAcePRc+k8OprV+GBgp+okFtNI/0sN/oNL/KBi4MoxacTdq/9CyH1eZOGr/qP2j9g99+6kNRu0fWvaP5r9R+0ftH7V/tP07MuwfqQAAcYgRdg=="
  OPEN_ICON = "eNrtlsENACEIBK3wSrnCbNJ73dOosIQQZxKfm0EhxNb8PP0dlhOd/yF/lp9x4l9lI+rfJSqfNf+Qt8NUvcNfy7+z3/Djx4+/ut+K8v5Kt/X9VW5P/xVu7/x53RXmXw3+Wn7+v3f5b+UD4HmCow=="
  PIN_ICON = "eNrtlksOABAMRN3KOR3RSdjaiKLU503S5XjBZHBuXjH4NDLafqlW+cupeaT7t/CfdH7leqP5ud0vzT+y6zCtu4N/Fl9b8O/itzpdytHOP3z4O/j0D/3Xk8Pd7z98+PDt+K/9/39VBiV4ujY="
  HELP_ICON = "eNpjYKAcTMzc958cTGv9MDBQ+ke6/4e6/oGOP2L1j4KBK8OoFXej9g8t+9HBqP0jy/7R/Dea/0fz36j9o/aP2j9a/43WP6P2D237RyoAAGYovgE="

  @main_window : UIng::Window?
  @preferences_window : UIng::Window?
  @toolbar : UIng::Toolbar?
  @toolbar_icons : Array(UIng::Image)

  def initialize
    @main_window = nil
    @preferences_window = nil
    @toolbar = nil
    @toolbar_icons = [] of UIng::Image

    setup_menus
    @main_window = UIng::Window.new("Control Gallery", 600, 500, menubar: true, margined: true) do
      on_closing do
        puts "Bye Bye"
        close_preferences
        release_toolbar
        UIng.quit
        true
      end
      set_child(build_content)
    end

    main_window.toolbar = build_toolbar
    main_window.show
  end

  def run
    UIng.main
  end

  private def main_window : UIng::Window
    @main_window || raise "main window has not been initialized"
  end

  private def preferences_open? : Bool
    if window = @preferences_window
      !window.released?
    else
      false
    end
  end

  private def close_preferences : Nil
    if window = @preferences_window
      window.destroy unless window.released?
      @preferences_window = nil
    end
  end

  private def icon(data : String) : UIng::Image
    pixels = Compress::Zlib::Reader.open(IO::Memory.new(Base64.decode(data))) do |zlib|
      zlib.getb_to_end
    end

    UIng::Image.new(16, 16).tap do |image|
      image.append(pixels[0, 16 * 16 * 4], 16, 16, 16 * 4)
      image.append(pixels[16 * 16 * 4, 32 * 32 * 4], 32, 32, 32 * 4)
    end
  end

  private def build_toolbar : UIng::Toolbar
    @toolbar_icons = [
      icon(NEW_ICON),
      icon(OPEN_ICON),
      icon(PIN_ICON),
      icon(HELP_ICON),
    ]

    UIng::Toolbar.new.tap do |toolbar|
      @toolbar = toolbar

      new_item = toolbar.append_button("New", @toolbar_icons[0])
      new_item.tooltip = "New document"
      new_item.on_clicked { puts "New clicked" }

      open_item = toolbar.append_button("Open", @toolbar_icons[1])
      open_item.tooltip = "Open document"
      open_item.on_clicked { puts main_window.open_file }

      toolbar.append_separator

      pinned_item = toolbar.append_toggle_button("Pinned", @toolbar_icons[2])
      pinned_item.tooltip = "Pin document"
      pinned_item.on_clicked { |item| puts "Pinned: #{item.checked?}" }

      toolbar.append_flexible_space

      help_item = toolbar.append_button("Help", @toolbar_icons[3])
      help_item.tooltip = "Show help"
      help_item.on_clicked do
        main_window.msg_box("Help", "This is the toolbar control.")
      end
    end
  end

  private def release_toolbar : Nil
    main_window.toolbar = nil

    @toolbar.try &.free
    @toolbar = nil

    @toolbar_icons.each &.free
    @toolbar_icons.clear
  end

  private def setup_menus : Nil
    UIng::Menu.new("File") do
      append_item("Open").on_clicked do |window|
        puts window.try &.open_file
      end
      append_item("Save").on_clicked do |window|
        puts window.try &.save_file
      end
      append_separator
      should_quit_item = append_check_item("Should Quit_", checked: true)
      append_quit_item

      # onShouldQuit callback is called when the user presses the quit menu item.
      UIng.on_should_quit do
        if should_quit_item.checked?
          puts "Bye Bye (on_should_quit)"
          close_preferences
          release_toolbar
          main_window.destroy # You have to destroy the window manually.
          true                # UIng.quit is automatically called in the C function onQuitClicked().
        else
          main_window.msg_box("Warning", "Please check \"Should Quit\"")
          false # Don"t quit
        end
      end

      append_preferences_item.on_clicked do
        create_preferences_window
      end
    end

    UIng::Menu.new("Edit") do
      append_check_item("Checkable Item_")
      append_separator
      disabled_item = append_item("Disabled Item_")
      disabled_item.disable
    end

    UIng::Menu.new("Help") do
      append_item("Help")
      append_about_item.on_clicked do
        UIng.msg_box("About", "This is a control gallery example.\nVersion: #{UIng::VERSION}")
      end
    end
  end

  private def build_content : UIng::Box
    vbox = UIng::Box.new(:vertical, padded: true)
    hbox = UIng::Box.new(:horizontal, padded: true)
    vbox.append(hbox, stretchy: true)

    hbox.append(build_basic_controls, stretchy: true)

    right_column = UIng::Box.new(:vertical, padded: true)
    hbox.append(right_column, true)
    right_column.append(build_numbers_group)
    right_column.append(build_lists_group)
    right_column.append(build_tab, true)

    vbox
  end

  private def build_basic_controls : UIng::Group
    group = UIng::Group.new("Basic Controls", margined: true)
    inner = UIng::Box.new(:vertical, padded: true)
    group.child = inner

    button = UIng::Button.new("Button") do
      on_clicked do
        main_window.msg_box("Information", "You clicked the button")
      end
    end
    inner.append(button, false)

    checkbox = UIng::Checkbox.new("Checkbox")
    checkbox.on_toggled do |checked|
      main_window.title = "Checkbox is #{checked}"
      checkbox.text = "I am the checkbox (#{checked})"
    end
    inner.append checkbox

    inner.append UIng::Label.new("Label")
    inner.append UIng::Separator.new(:horizontal)

    dp = UIng::DateTimePicker.new(:date) do
      on_changed do |time|
        puts "DateTimePicker changed: #{time}"
      end
    end
    inner.append dp

    tp = UIng::DateTimePicker.new(:time) do
      on_changed do |time|
        puts "TimePicker changed: #{time}"
      end
    end
    inner.append tp

    dtp = UIng::DateTimePicker.new do
      on_changed do |time|
        puts "DateTimePicker changed: #{time}"
      end
    end
    inner.append dtp

    font_button = UIng::FontButton.new do
      on_changed do |font_descriptor|
        puts "Font changed: family=#{font_descriptor.family}, size=#{font_descriptor.size}, weight=#{font_descriptor.weight}, italic=#{font_descriptor.italic}, stretch=#{font_descriptor.stretch}"
      end
    end
    inner.append font_button

    color_button = UIng::ColorButton.new do
      on_changed do |red, green, blue, alpha|
        puts "Color changed: R=#{red}, G=#{green}, B=#{blue}, A=#{alpha}"
      end
    end
    inner.append color_button

    group
  end

  private def build_numbers_group : UIng::Group
    group = UIng::Group.new("Numbers", margined: true)
    inner = UIng::Box.new(:vertical, padded: true)
    group.child = inner

    spinbox = UIng::Spinbox.new(0, 100, value: 42) do
      on_changed { |v| puts "New Spinbox value: #{v}" }
    end
    inner.append spinbox

    slider = UIng::Slider.new(0, 100)
    inner.append slider

    progressbar = UIng::ProgressBar.new
    inner.append progressbar

    slider.on_changed do |v|
      puts "New Slider value: #{v}"
      progressbar.value = v
    end

    group
  end

  private def build_lists_group : UIng::Group
    group = UIng::Group.new("Lists", margined: true)
    inner = UIng::Box.new(:vertical, padded: true)
    group.child = inner

    cbox = UIng::Combobox.new ["Combobox Item 1", "Combobox Item 2", "Combobox Item 3"]
    inner.append cbox
    cbox.on_selected do |idx|
      puts "New combobox selection: #{idx}"
    end

    ebox = UIng::EditableCombobox.new ["Editable Item 1", "Editable Item 2", "Editable Item 3"]
    inner.append ebox
    ebox.on_changed do |text|
      puts "Editable Combobox changed: #{text}"
    end

    rb = UIng::RadioButtons.new ["Radio Button 1", "Radio Button 2", "Radio Button 3"]
    inner.append(rb, true)
    rb.on_selected do |idx|
      puts "Radio button selected: index #{idx}"
    end

    group
  end

  private def build_tab : UIng::Tab
    tab = UIng::Tab.new
    hbox1 = UIng::Box.new(:horizontal)
    tab.append("Page 1", hbox1)
    tab.append("Page 2", UIng::Box.new(:horizontal))
    tab.append("Page 3", UIng::Box.new(:horizontal))
    tab.on_selected do |idx|
      puts "Tab selected: index #{idx}"
    end

    text_entry = UIng::Entry.new
    text_entry.text = "Please enter your feelings"
    text_entry.on_changed do
      print "Current textbox data: "
      puts text_entry.text
    end
    hbox1.append(text_entry, true)

    tab
  end

  private def create_preferences_window : Nil
    return if preferences_open?

    UIng::Window.new("Preferences", 300, 200, margined: true) do |window|
      @preferences_window = window

      on_closing do
        puts "Preferences window closed"
        @preferences_window = nil
        true # Allow closing
      end
      set_child(build_preferences_content)
      show

      x = main_window.position[0] + main_window.content_size[0] / 2 - content_size[0] / 2
      y = main_window.position[1] + main_window.content_size[1] / 2 - content_size[1] / 2
      set_position(x.to_i, y.to_i)
    end
  end

  private def build_preferences_content : UIng::Box
    UIng::Box.new(:vertical, padded: true) do
      label = UIng::Label.new("Preferences")
      append(label, stretchy: false)
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
  end
end

UIng.init
ControlGalleryApp.new.run
UIng.uninit
