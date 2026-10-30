require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::ToolbarItem do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    it "allows checked state only on toggle ToolbarItems" do
      toolbar = UIng::Toolbar.new
      button = toolbar.append_button("Action")
      toggle = toolbar.append_toggle_button("Enabled")

      expect_raises(ArgumentError, /only available for toggle ToolbarItems/) { button.checked? }
      expect_raises(ArgumentError, /only available for toggle ToolbarItems/) { button.checked = true }

      toggle.checked = true
      toggle.checked?.should be_true
      toggle.checked = false
      toggle.checked?.should be_false
    ensure
      toolbar.try &.free
    end
  end
{% end %}
