require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe "native Menu configuration blocks" do
    it "configures retained items and returns each item instead of its block value" do
      UIng.init
      begin
        menu = UIng::Menu.new("File")
        configured = nil
        open_item = menu.append_item("Open") do |item|
          configured = item
          to_unsafe.should eq(item.to_unsafe)
          set_shortcut('O', UIng::Modifiers::Primary)
          on_clicked { |_window| }
          :ignored
        end
        open_item.should be(configured)
        open_item.clear_on_clicked

        checked = menu.append_check_item("Checked", checked: true) do
          checked?.should be_true
          on_clicked { |_window| }
        end
        checked.checked?.should be_true
        unchecked = menu.append_check_item("Unchecked") { checked?.should be_false }
        unchecked.checked?.should be_false

        preferences = menu.append_preferences_item { on_clicked { |_window| } }
        about = menu.append_about_item { on_clicked { |_window| } }
        quit = menu.append_quit_item { clear_on_clicked }
        [open_item, checked, unchecked, preferences, about, quit].each do |item|
          item.to_unsafe.null?.should be_false
        end
        expect_raises(ArgumentError, /UIng\.on_should_quit/) do
          quit.on_clicked { |_window| }
        end
      ensure
        UIng.uninit
      end
    end
  end
{% end %}
