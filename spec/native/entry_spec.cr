require "../spec_helper"
require "../support/native_controls"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Entry do
    before_all { UIng.init }
    after_all { UIng.uninit }

    describe "entry variants" do
      it "round-trips UTF-8 and empty text in every native entry variant" do
        UIng::Entry::Type.each do |type|
          SpecSupport.with_native_control(UIng::Entry.new(type)) do |entry|
            ["日本語", "", "replacement"].each do |text|
              entry.text = text
              entry.text.should eq(text)
            end
          end
        end
      end
    end

    describe "read-only state" do
      it "honors the constructor option and permits programmatic text changes" do
        SpecSupport.with_native_control(UIng::Entry.new(read_only: true)) do |entry|
          entry.read_only?.should be_true
          entry.text = "programmatic change"
          entry.text.should eq("programmatic change")

          entry.read_only = false
          entry.read_only?.should be_false
          entry.read_only = true
          entry.read_only?.should be_true
        end
      end
    end
  end
{% end %}
