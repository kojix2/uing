require "../../src/uing"

UIng.init

UIng::Menu.new("File") do
  append_item("Open") do
    set_shortcut('O', UIng::Modifiers::Primary)
    on_clicked do |window|
      window.try &.open_file
    end
  end
  append_separator
  append_preferences_item do
    on_clicked do |window|
      window.try &.msg_box("Preferences", "Preferences clicked")
    end
  end
  append_separator
  append_quit_item
end

UIng::Menu.new("Edit") do
  append_check_item("Check", checked: false) do
    on_clicked do |_menu_window|
      # No-op
    end
  end
  append_separator
  append_item("Click") do
    on_clicked do |window|
      window.try &.msg_box("Click", "Click menu clicked")
    end
  end
end

UIng::Menu.new("Help") do
  append_about_item do
    on_clicked do |window|
      window.try &.msg_box("About", "Menu example")
    end
  end
end

# Window must be created after menu finalized.
Window = UIng::Window.new("Menu Example", 300, 50, menubar: true) do
  on_closing do
    UIng.quit
    true
  end

  show
end

UIng.on_should_quit do
  Window.destroy unless Window.released?
  true
end

{% if flag?(:darwin) %}
  label = UIng::Label.new("The Mac menu bar is at the top of the screen.")
  Window.child = label
{% end %}

UIng.main

UIng.uninit
