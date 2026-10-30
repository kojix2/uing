require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::FontButton do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    it "keeps FontButton descriptor snapshots independent" do
      button = UIng::FontButton.new
      retained = button.font
      snapshot = retained.snapshot
      retained.family.empty?.should be_false
      retained.size.should be > 0
      snapshot.family.empty?.should be_false
      snapshot.size.should be > 0
      retained.family = "Changed"
      snapshot.family.should_not eq("Changed")
    ensure
      button.try &.destroy
    end

    it "returns a managed FontButton descriptor" do
      button = UIng::FontButton.new
      descriptor = button.font
      button.destroy

      descriptor.family.empty?.should be_false
      descriptor.size.should be > 0
      String.new(descriptor.to_unsafe.value.family).should eq(descriptor.family)
    ensure
      button.try { |control| control.destroy unless control.released? }
    end
  end
{% end %}
