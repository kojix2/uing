require "../spec_helper"
require "../support/native_controls"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Label do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    it "sets and resets a Label font size" do
      SpecSupport.with_native_control(UIng::Label.new("Text")) do |label|
        default_size = label.font_size

        label.font_size = 18.5
        label.font_size.should be_close(18.5, 0.000001)

        label.text = "Changed"
        label.font_size.should be_close(18.5, 0.000001)

        label.reset_font_size
        label.font_size.should be_close(default_size, 0.000001)
      end
    end

    it "preserves UTF-8 labels through construction, replacement, and clearing" do
      SpecSupport.with_native_control(UIng::Label.new("日本語")) do |label|
        label.text.should eq("日本語")

        ["Changed", ""].each do |text|
          label.text = text
          label.text.should eq(text)
        end
      end
    end
  end
{% end %}
