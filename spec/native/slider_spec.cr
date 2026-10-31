require "../spec_helper"
require "../support/native_controls"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Slider do
    before_all { UIng.init }
    after_all { UIng.uninit }

    describe "values and ranges" do
      it "sets the initial value and clamps assignments to a signed range" do
        SpecSupport.with_native_control(UIng::Slider.new(-5, 5, 3)) do |slider|
          slider.value.should eq(3)
          slider.value = -10
          slider.value.should eq(-5)
          slider.value = 10
          slider.value.should eq(5)
        end
      end

      it "applies range changes through each public overload" do
        SpecSupport.with_native_control(UIng::Slider.new(0, 100, 50)) do |slider|
          slider.range = 10..20
          slider.value.should eq(20)
          slider.set_range(-5, 5)
          slider.value.should eq(5)
          slider.set_range(0...4)
          slider.value.should eq(3)
          slider.value = -1
          slider.value.should eq(0)
        end
      end
    end

    describe "value tooltips" do
      it "disables and restores the native value tooltip" do
        SpecSupport.with_native_control(UIng::Slider.new(0, 100)) do |slider|
          slider.has_tool_tip = false
          slider.has_tool_tip?.should be_false
          slider.has_tool_tip = true
          slider.has_tool_tip?.should be_true
        end
      end
    end
  end
{% end %}
