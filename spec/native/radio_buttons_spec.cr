require "../spec_helper"
require "../support/native_controls"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::RadioButtons do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "represents an empty selection as nil and can clear a selected index" do
      SpecSupport.with_native_control(UIng::RadioButtons.new(["first", "second"])) do |buttons|
        buttons.selected.should be_nil
        buttons.selected = 1
        buttons.selected.should eq(1)
        buttons.selected = nil
        buttons.selected.should be_nil
      end
    end

    it "selects items appended after construction" do
      SpecSupport.with_native_control(UIng::RadioButtons.new) do |buttons|
        buttons.append("first")
        buttons.append("日本語")

        buttons.selected = 0
        buttons.selected.should eq(0)
        buttons.selected = 1
        buttons.selected.should eq(1)
      end
    end
  end
{% end %}
