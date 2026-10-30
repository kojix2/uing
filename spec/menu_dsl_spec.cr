require "./spec_helper"

describe "Menu configuration blocks" do
  it "supports implicit MenuItem receivers and returns MenuItem for every item kind" do
    # Instantiate the DSL blocks without creating native application menus.
    typeof(UIng::Menu.new("File").append_item("Open") do
      set_shortcut('O', UIng::Modifiers::Primary)
      on_clicked { |_window| }
    end).should eq(UIng::MenuItem)
    typeof(UIng::Menu.new("Edit").append_check_item("Check") { checked? }).should eq(UIng::MenuItem)
    typeof(UIng::Menu.new("Edit").append_check_item("Check", checked: true) { checked? }).should eq(UIng::MenuItem)
    typeof(UIng::Menu.new("File").append_preferences_item { on_clicked { |_window| } }).should eq(UIng::MenuItem)
    typeof(UIng::Menu.new("Help").append_about_item { on_clicked { |_window| } }).should eq(UIng::MenuItem)
    typeof(UIng::Menu.new("File").append_quit_item { clear_on_clicked }).should eq(UIng::MenuItem)
  end
end
