require "../spec_helper"
require "../support/native_controls"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Spinbox do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "sets the initial value and accepts both endpoints of a signed range" do
      SpecSupport.with_native_control(UIng::Spinbox.new(-5, 5, 3)) do |spinbox|
        spinbox.value.should eq(3)

        [-5, 0, 5].each do |value|
          spinbox.value = value
          spinbox.value.should eq(value)
        end
      end
    end

    it "clamps values outside the native range" do
      SpecSupport.with_native_control(UIng::Spinbox.new(-5, 5)) do |spinbox|
        spinbox.value = -10
        spinbox.value.should eq(-5)
        spinbox.value = 10
        spinbox.value.should eq(5)
      end
    end
  end
{% end %}
