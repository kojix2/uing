require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Label do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    it "sets and resets a Label font size" do
      label = UIng::Label.new("Text")
      default_size = label.font_size

      label.font_size = 18.5
      label.font_size.should be_close(18.5, 0.000001)

      label.text = "Changed"
      label.font_size.should be_close(18.5, 0.000001)

      label.reset_font_size
      label.font_size.should be_close(default_size, 0.000001)
    ensure
      label.try &.destroy
    end

    it "rejects invalid Label font sizes before calling libui-ng" do
      label = UIng::Label.new("Text")

      [0, -1, Float64::NAN, Float64::INFINITY].each do |size|
        expect_raises(ArgumentError, /finite and positive/) { label.font_size = size }
      end
    ensure
      label.try &.destroy
    end
  end
{% end %}
