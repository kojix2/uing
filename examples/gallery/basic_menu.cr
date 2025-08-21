require "../../src/uing"

UIng.init

UIng::Menu.new("File") do
  append_item("Open").on_clicked do |w|
    Window.open_file
  end
  append_separator
  append_preferences_item.on_clicked do |w|
    UIng.msg_box(w, "Preferences", "Preferences clicked")
  end
  append_separator
  append_quit_item
end

UIng::Menu.new("Edit") do
  append_check_item("Check", checked: false).on_clicked do |w|
    # No-op
  end
  append_separator
  append_item("Click").on_clicked do |w|
    UIng.msg_box(w, "Click", "Click menu clicked")
  end
end

UIng::Menu.new("Help") do
  append_about_item.on_clicked do |w|
    UIng.msg_box(w, "About", "Menu example")
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

{% if flag?(:darwin) %}
  label = UIng::Label.new("The Mac menu bar is at the top of the screen.")
  Window.set_child(label)
{% end %}

UIng.main

UIng.uninit
