require "../spec_helper"
require "../support/native_controls"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::ProgressBar do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "switches between determinate progress and the indeterminate sentinel" do
      SpecSupport.with_native_control(UIng::ProgressBar.new) do |progress|
        [0, 37, 100, -1, 0, 100].each do |value|
          progress.value = value
          progress.value.should eq(value)
        end
      end
    end
  end
{% end %}
