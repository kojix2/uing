require "../spec_helper"
require "../support/native_controls"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::ColorButton do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "round-trips RGBA values including transparent and opaque endpoints" do
      SpecSupport.with_native_control(UIng::ColorButton.new) do |button|
        [{0, 1, 0, 0}, {0.2, 0.4, 0.6, 0.5}, {1, 0, 1, 1}].each do |color|
          button.set_color(*color)
          button.color.zip(color).each do |actual, expected|
            actual.should be_close(expected, 0.000001)
          end
        end
      end
    end
  end
{% end %}
