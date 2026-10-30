require "../../spec_helper"
require "../../support/drop_targets"

describe UIng::Drop::Target do
  describe "callback registration" do
    it "dispatches closures without a target argument and clears the registration" do
      window = SpecSupport::DropWindowForSpec.new
      window.clear_on_drop
      received = [] of String
      window.on_drop(accepts: :text) { |event| received << (event.text || ""); true }
      GC.collect
      info = UIng::LibUI::DropInfo.new(format: UIng::LibUI::DropFormat::Text, x: -1.0)
      payload = UIng::LibUI::DropData.new(format: UIng::LibUI::DropFormat::Text, text: "hello".to_unsafe, text_length: LibC::SizeT.new(5))
      native = window.native_handler
      data = window.user_data
      native.over.call(pointerof(info), data).should eq(UIng::LibUI::DropAction::Copy)
      native.leave.call(data)
      native.drop.call(pointerof(info), pointerof(payload), data).should eq(UIng::LibUI::DropResult::Accepted)
      received.should eq(["hello"])
      window.on_drop(nil)
      window.drop_handler.should be_nil
    ensure
      window.try &.destroy
    end

    it "replaces the callback and preserves it on native registration failure" do
      window = SpecSupport::DropWindowForSpec.new
      window.on_drop(accepts: :text) { |_event| true }
      original = window.drop_handler
      window.status = UIng::LibUI::DropStatus::NativeError
      expect_raises(UIng::Drop::Error) { window.on_drop(accepts: :files) { |_event| false } }
      expect_raises(UIng::Drop::Error) { window.clear_on_drop }
      window.drop_handler.should be(original)
      window.status = UIng::LibUI::DropStatus::OK
      info = UIng::LibUI::DropInfo.new(format: UIng::LibUI::DropFormat::Text)
      payload = UIng::LibUI::DropData.new(format: UIng::LibUI::DropFormat::Text, text: "".to_unsafe)
      window.native_handler.drop.call(pointerof(info), pointerof(payload), window.user_data).should eq(UIng::LibUI::DropResult::Accepted)
      window.on_drop(accepts: :files) { |_event| false }
      window.drop_handler.should_not be(original)
      window.drop_handler.try(&.accepts).should eq(UIng::Drop::Format::Files)
      info.format = UIng::LibUI::DropFormat::Files
      payload = UIng::LibUI::DropData.new(format: UIng::LibUI::DropFormat::Files)
      window.native_handler.drop.call(pointerof(info), pointerof(payload), window.user_data).should eq(UIng::LibUI::DropResult::Rejected)
    ensure
      window.try &.destroy
    end
  end

  describe "callback lifetime and ownership" do
    it "can unregister itself and collect garbage while retaining the received data" do
      window = SpecSupport::DropWindowForSpec.new
      received = nil.as(UIng::Drop::Event?)
      window.on_drop(accepts: :text) do |event|
        window.clear_on_drop
        GC.collect
        received = event
        true
      end
      info = UIng::LibUI::DropInfo.new(format: UIng::LibUI::DropFormat::Text)
      payload = UIng::LibUI::DropData.new(format: UIng::LibUI::DropFormat::Text, text: "".to_unsafe)
      window.native_handler.drop.call(pointerof(info), pointerof(payload), window.user_data).should eq(UIng::LibUI::DropResult::Accepted)
      received.should be_a(UIng::Drop::Event)
      window.drop_handler.should be_nil
    ensure
      window.try &.destroy
    end

    it "protects explicit Handlers and rejects calls after destruction" do
      window = SpecSupport::DropWindowForSpec.new
      explicit = UIng::Drop::Handler.new { drop { |_target, _event| true } }
      window.drop_handler = explicit
      expect_raises(ArgumentError, /explicit Handler/) { window.on_drop { |_event| true } }
      expect_raises(ArgumentError, /explicit Handler/) { window.clear_on_drop }
      window.drop_handler.should be(explicit)
      window.clear_drop_handler
      window.on_drop { |_event| true }
      window.destroy
      expect_raises(Exception, /destroyed/) { window.on_drop { |_event| true } }
      expect_raises(Exception, /destroyed/) { window.clear_on_drop }
    ensure
      window.try &.destroy
    end
  end
end
