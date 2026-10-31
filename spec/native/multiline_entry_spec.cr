require "../spec_helper"
require "../support/native_controls"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::MultilineEntry do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    describe "text" do
      it "appends and clears UTF-8 lines in both wrapping modes" do
        [true, false].each do |wrapping|
          SpecSupport.with_native_control(UIng::MultilineEntry.new(wrapping: wrapping)) do |entry|
            entry.text = "first\n"
            entry.append("日本語")
            entry.text.should eq("first\n日本語")
            entry.text = ""
            entry.text.should eq("")
          end
        end
      end
    end

    describe "read-only state" do
      it "honors the constructor option and permits programmatic text changes in both wrapping modes" do
        [true, false].each do |wrapping|
          SpecSupport.with_native_control(UIng::MultilineEntry.new(wrapping: wrapping, read_only: true)) do |entry|
            entry.read_only?.should be_true
            entry.text = "first\n"
            entry.append("日本語")
            entry.text.should eq("first\n日本語")

            entry.read_only = false
            entry.read_only?.should be_false
            entry.read_only = true
            entry.read_only?.should be_true
          end
        end
      end
    end

    describe "font size" do
      it "sets and resets a MultilineEntry font size" do
        SpecSupport.with_native_control(UIng::MultilineEntry.new) do |entry|
          default_size = entry.font_size

          entry.font_size = 18.5
          entry.font_size.should be_close(18.5, 0.000001)

          entry.text = "Changed"
          entry.font_size.should be_close(18.5, 0.000001)

          entry.reset_font_size
          entry.font_size.should be_close(default_size, 0.000001)
        end
      end
    end
  end
{% end %}
