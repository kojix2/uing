require "../spec_helper"

if ENV["UING_NATIVE_GUI_TESTS"]? == "1"
  describe "libui-ng dev APIs" do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "registers and clears an Area handler scroll callback" do
      window = UIng::Window.new("Area scroll callback", 300, 200)
      handler = UIng::Area::Handler.new
      handler.scroll_event { |_area, _event| true }
      area = UIng::Area.new(handler)
      window.child = area
      begin
        handler.scroll_event(nil)
      ensure
        window.destroy
      end
    end

    it "requests control focus and queries the result" do
      window = UIng::Window.new("Control focus", 300, 200)
      entry = UIng::Entry.new
      window.child = entry
      begin
        window.show
        entry.focus
        entry.focused?.should be_a(Bool)
      ensure
        window.destroy
      end
    end

    it "adds rounded rectangles to native paths" do
      path = UIng::Area::Draw::Path.new(:winding)
      begin
        path.add_rounded_rectangle(10, 20, 80, 40, 8).should be(path)
        path.end_path
        path.ended?.should be_true
      ensure
        path.free
      end
    end

    it "releases a native Path when its configuration block raises" do
      escaped = nil
      expect_raises(Exception, "path configuration failed") do
        UIng::Area::Draw::Path.new(UIng::Area::Draw::FillMode::Winding) do |path|
          escaped = path
          path.new_figure(0, 0).line_to(10, 10)
          raise "path configuration failed"
        end
      end

      path = escaped.should_not be_nil
      path.ended?.should be_true
      path.released?.should be_true
      expect_raises(Exception, /already freed/) { path.to_unsafe }
      path.free # Repeated cleanup must not free native memory twice.
    end

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
end
