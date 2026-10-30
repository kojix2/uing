require "../../../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Area::Draw::TextLayout do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    it "releases a native TextLayout even if it was freed before the block raises" do
      UIng::Area::AttributedString.open("cleanup") do |string|
        [false, true].each do |free_early|
          escaped = nil
          expect_raises(Exception, "layout configuration failed") do
            UIng::Area::Draw::TextLayout.new(string: string,
              default_font: UIng::FontDescriptor.new(family: "sans-serif"), width: 100) do |layout|
              escaped = layout
              layout.free if free_early
              raise "layout configuration failed"
            end
          end

          layout = escaped.should_not be_nil
          expect_raises(Exception, /already been released/) { layout.to_unsafe }
          layout.free
        end
      end
    end
  end
{% end %}
