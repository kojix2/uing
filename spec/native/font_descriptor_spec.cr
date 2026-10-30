require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::FontDescriptor do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    it "loads the default control font into a managed descriptor" do
      descriptor = UIng::FontDescriptor.new

      descriptor.family.empty?.should be_false
      descriptor.size.should be > 0
      String.new(descriptor.to_unsafe.value.family).should eq(descriptor.family)
    end
  end
{% end %}
