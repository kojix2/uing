require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Area do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    it "rejects scrolling calls on an ordinary Area before entering libui-ng" do
      window = UIng::Window.new("Area mode check", 300, 200)
      area = UIng::Area.new do
        on_draw { |_params| }
        on_mouse_event { |_event| }
      end
      window.child = area
      begin
        expect_raises(ArgumentError, /set_size requires a scrolling Area/) { area.set_size(200, 100) }
        expect_raises(ArgumentError, /scroll_to requires a scrolling Area/) { area.scroll_to(0, 0, 20, 20) }
      ensure
        window.destroy
      end
    end

    it "allows both calls on a scrolling Area" do
      window = UIng::Window.new("Scrolling Area mode check", 300, 200)
      area = UIng::Area.new(200, 100) do
        on_draw { |_params| }
      end
      window.child = area
      begin
        area.set_size(300, 150)
        area.scroll_to(20, 10, 40, 30)
      ensure
        window.destroy
      end
    end
  end
{% end %}
