require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe "Combobox and RadioButtons selections" do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    it "represents empty combobox and radio-button selections as nil" do
      combobox = UIng::Combobox.new(["first", "second"])
      radio_buttons = UIng::RadioButtons.new(["first", "second"])

      combobox.selected.should be_nil
      radio_buttons.selected.should be_nil

      combobox.selected = 1
      radio_buttons.selected = 1
      combobox.selected.should eq(1)
      radio_buttons.selected.should eq(1)

      combobox.selected = nil
      radio_buttons.selected = nil
      combobox.selected.should be_nil
      radio_buttons.selected.should be_nil
    ensure
      combobox.try &.destroy
      radio_buttons.try &.destroy
    end
  end
{% end %}
