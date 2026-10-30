require "../../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Area::Handler do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

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
  end
{% end %}
