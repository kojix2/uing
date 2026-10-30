require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::MultilineEntry do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    it "sets and resets a MultilineEntry font size" do
      entry = UIng::MultilineEntry.new
      default_size = entry.font_size

      entry.font_size = 18.5
      entry.font_size.should be_close(18.5, 0.000001)

      entry.text = "Changed"
      entry.font_size.should be_close(18.5, 0.000001)

      entry.reset_font_size
      entry.font_size.should be_close(default_size, 0.000001)
    ensure
      entry.try &.destroy
    end

    it "rejects invalid MultilineEntry font sizes before calling libui-ng" do
      entry = UIng::MultilineEntry.new

      [0, -1, Float64::NAN, Float64::INFINITY].each do |size|
        expect_raises(ArgumentError, /finite and positive/) { entry.font_size = size }
      end
    ensure
      entry.try &.destroy
    end
  end
{% end %}
