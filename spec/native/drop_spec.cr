require "../spec_helper"

module UIng::Drop::Target
  def drop_user_data_for_spec : Pointer(Void)
    (@drop_context || raise "no drop context").as(Void*)
  end
end

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe "native drop handlers" do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "registers and clears handler-free callbacks on Window and Area" do
      window = UIng::Window.new("Drop callbacks", 300, 200)
      area = UIng::Area.new(UIng::Area::Handler.new)
      window.child = area
      received = [] of String
      targets = [window, area] of UIng::Drop::Target
      targets.each do |target|
        target.on_drop(accepts: :text) { |event| received << (event.text || ""); true }
      end
      GC.collect
      info = UIng::LibUI::DropInfo.new(format: UIng::LibUI::DropFormat::Text, x: -1.0)
      payload = UIng::LibUI::DropData.new(format: UIng::LibUI::DropFormat::Text, text: "hello".to_unsafe, text_length: LibC::SizeT.new(5))
      targets.each do |target|
        handler = target.drop_handler || raise "missing drop handler"
        native = handler.to_unsafe.value
        data = target.drop_user_data_for_spec
        native.over.call(pointerof(info), data).should eq(UIng::LibUI::DropAction::Copy)
        native.leave.call(data)
        native.drop.call(pointerof(info), pointerof(payload), data).should eq(UIng::LibUI::DropResult::Accepted)
        target.on_drop(nil)
        target.drop_handler.should be_nil
      end
      received.should eq(["hello", "hello"])
    ensure
      window.try { |owner| owner.destroy unless owner.released? }
    end

    it "registers one handler on Window and Area and clears them independently" do
      window = UIng::Window.new("Drop handler", 300, 200)
      area = UIng::Area.new(UIng::Area::Handler.new)
      window.child = area
      dropped = [] of UIng::Control
      hovered = [] of UIng::Control
      left = [] of UIng::Control
      handler = UIng::Drop::Handler.new(accepts: :files) do
        drop { |target, _event| dropped << target; true }
        over { |target, _info| hovered << target; true }
        leave { |target| left << target }
      end
      window.drop_handler = handler
      area.drop_handler = handler
      GC.collect
      window.drop_handler.should be(handler)
      area.drop_handler.should be(handler)

      info = UIng::LibUI::DropInfo.new(format: UIng::LibUI::DropFormat::Files)
      payload = UIng::LibUI::DropData.new(format: UIng::LibUI::DropFormat::Files)
      native = handler.to_unsafe.value
      targets = [window, area] of UIng::Drop::Target
      targets.each do |target|
        data = target.drop_user_data_for_spec
        native.over.call(pointerof(info), data).should eq(UIng::LibUI::DropAction::Copy)
        native.leave.call(data)
        native.drop.call(pointerof(info), pointerof(payload), data).should eq(UIng::LibUI::DropResult::Accepted)
      end
      dropped.should eq([window, area])
      hovered.should eq([window, area])
      left.should eq([window, area])

      window.drop_handler = nil
      window.drop_handler.should be_nil
      area.drop_handler.should be(handler)
      window.clear_drop_handler
      area.drop_handler = UIng::Drop::Handler.new { drop { |_target, _event| false } }
      area.drop_handler.should_not be(handler)
      area.clear_drop_handler
      area.drop_handler.should be_nil

      area.drop_handler = handler
      window.drop_handler = handler
      window.destroy
      UIng.main_steps
      deadline = Time.instant + 5.seconds
      until area.parent.nil?
        UIng.main_step(false)
        raise "timed out waiting for Area destruction" if Time.instant >= deadline
      end
      expect_raises(Exception, /destroyed/) { window.drop_handler }
      expect_raises(Exception, /destroyed/) { area.clear_drop_handler }
    ensure
      window.try { |owner| owner.destroy unless owner.released? }
    end
  end
{% end %}
