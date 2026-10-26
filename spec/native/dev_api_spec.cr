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
  end
end
