require "../spec_helper"
require "../support/native_controls"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Checkbox do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "preserves its checked state when the UTF-8 label is changed" do
      SpecSupport.with_native_control(UIng::Checkbox.new("選択")) do |checkbox|
        checkbox.text.should eq("選択")
        checkbox.checked?.should be_false

        checkbox.checked = true
        checkbox.text = "変更"
        checkbox.text.should eq("変更")
        checkbox.checked?.should be_true
        checkbox.checked = false
        checkbox.text = ""
        checkbox.text.should eq("")
        checkbox.checked?.should be_false
      end
    end
  end
{% end %}
