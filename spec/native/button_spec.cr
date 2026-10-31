require "../spec_helper"
require "../support/native_controls"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Button do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "preserves UTF-8 labels through construction, replacement, and clearing" do
      SpecSupport.with_native_control(UIng::Button.new("実行")) do |button|
        button.text.should eq("実行")

        ["変更", "", "Run"].each do |text|
          button.text = text
          button.text.should eq(text)
        end
      end
    end
  end
{% end %}
