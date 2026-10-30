require "../../../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Area::Draw::Path do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

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
  end
{% end %}
