require "./spec_helper"

private class DropWindowForSpec < UIng::Window
  getter native_handler = UIng::LibUI::DropHandler.new
  getter user_data = Pointer(Void).null
  property status = UIng::LibUI::DropStatus::OK

  def initialize
    @ref_ptr = Pointer(UIng::LibUI::Window).null
  end

  protected def set_native_drop_handler(formats : LibC::UInt, handler : UIng::LibUI::DropHandler*, data : Void*) : UIng::LibUI::DropStatus
    return @status unless @status.ok?
    @native_handler = handler.null? ? UIng::LibUI::DropHandler.new : handler.value
    @user_data = data
    @status
  end

  def destroy : Nil
    return if released?
    @user_data = Pointer(Void).null
    mark_destroyed_from_native
  end
end

describe "drop callback shortcuts" do
  it "dispatches closures without a target argument and clears the registration" do
    window = DropWindowForSpec.new
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
    window = DropWindowForSpec.new
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

  it "protects explicit Handlers and rejects calls after destruction" do
    window = DropWindowForSpec.new
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

  it "can unregister itself and collect garbage while retaining the received data" do
    window = DropWindowForSpec.new
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
end

private def install_drop_closures_for_spec(window : DropWindowForSpec) : Array(String)
  count = 0
  log = [] of String
  window.drop_handler = UIng::Drop::Handler.new(accepts: :text) do
    over { |_target, _info| count += 1; log << "over:#{count}"; true }
    leave { |_target| count += 1; log << "leave:#{count}" }
    drop do |target, event|
      target.clear_drop_handler
      GC.collect
      count += 1
      log << "drop:#{count}:#{event.text}"
      true
    end
  end
  log
end

describe UIng::Drop::Handler do
  it "retains captured state after its defining method returns and during self-removal" do
    window = DropWindowForSpec.new
    log = install_drop_closures_for_spec(window)
    GC.collect
    native = window.native_handler
    data = window.user_data
    native.release_user_data.pointer.null?.should be_true
    info = UIng::LibUI::DropInfo.new(format: UIng::LibUI::DropFormat::Text)
    payload = UIng::LibUI::DropData.new(format: UIng::LibUI::DropFormat::Text, text: "hello".to_unsafe, text_length: LibC::SizeT.new(5))
    native.over.call(pointerof(info), data).should eq(UIng::LibUI::DropAction::Copy)
    native.leave.call(data)
    GC.collect
    native.drop.call(pointerof(info), pointerof(payload), data).should eq(UIng::LibUI::DropResult::Accepted)
    log.should eq(["over:1", "leave:2", "drop:3:hello"])
    window.drop_handler.should be_nil
  ensure
    window.try &.destroy
  end

  it "copies metadata and UTF-8 text into a retainable event" do
    window = DropWindowForSpec.new
    received = nil.as(UIng::Drop::Event?)
    handler = UIng::Drop::Handler.new(accepts: :text) do
      drop { |_target, event| received = event; true }
    end
    window.drop_handler = handler
    text = "日本語".to_slice.dup
    info = UIng::LibUI::DropInfo.new(formats: 3_u32, format: UIng::LibUI::DropFormat::Text, x: 12.5, y: 7.25)
    payload = UIng::LibUI::DropData.new(format: UIng::LibUI::DropFormat::Text, text: text.to_unsafe, text_length: LibC::SizeT.new(text.size))
    result = window.native_handler.drop.call(pointerof(info), pointerof(payload), window.user_data)
    text.fill(0_u8)
    info.x = 100.0
    window.destroy

    result.should eq(UIng::LibUI::DropResult::Accepted)
    event = received.should be_a(UIng::Drop::Event)
    event.text.should eq("日本語")
    event.files.should be_nil
    event.formats.should eq(UIng::Drop::Format::All)
    event.format.should eq(UIng::Drop::Format::Text)
    {event.x, event.y}.should eq({12.5, 7.25})
  ensure
    window.try &.destroy
  end

  it "copies file paths including non-UTF-8 bytes and preserves their order" do
    window = DropWindowForSpec.new
    received = nil.as(UIng::Drop::Event?)
    handler = UIng::Drop::Handler.new(accepts: :files) do
      drop { |_target, event| received = event; false }
    end
    window.drop_handler = handler
    first = Bytes[47, 255, 0]
    second = Bytes[47, 100, 105, 114, 0]
    paths = [first.to_unsafe, second.to_unsafe, Pointer(LibC::Char).null]
    info = UIng::LibUI::DropInfo.new(format: UIng::LibUI::DropFormat::Files)
    payload = UIng::LibUI::DropData.new(format: UIng::LibUI::DropFormat::Files, files: paths.to_unsafe, file_count: LibC::SizeT.new(2))
    window.native_handler.drop.call(pointerof(info), pointerof(payload), window.user_data).should eq(UIng::LibUI::DropResult::Rejected)
    first.fill(0_u8)
    second.fill(0_u8)
    window.destroy

    event = received.should be_a(UIng::Drop::Event)
    event.text.should be_nil
    files = event.files.should be_a(Array(String))
    files.first.bytes.should eq([47_u8, 255_u8])
    files.last.should eq("/dir")
    files.clear
    event.files.should eq([String.new(Bytes[47, 255]), "/dir"])
  ensure
    window.try &.destroy
  end

  it "dispatches and clears hover callbacks and accepts compatible offers by default" do
    window = DropWindowForSpec.new
    handler = UIng::Drop::Handler.new { drop { |_target, _event| true } }
    window.drop_handler = handler
    info = UIng::LibUI::DropInfo.new(format: UIng::LibUI::DropFormat::Files, x: 20.0)
    native = window.native_handler
    data = window.user_data
    native.over.call(pointerof(info), data).should eq(UIng::LibUI::DropAction::Copy)
    positions = [] of Float64
    handler.over { |_target, offer| positions << offer.x; false }
    native.over.call(pointerof(info), data).should eq(UIng::LibUI::DropAction::None)
    positions.should eq([20.0])
    handler.over(nil)
    native.over.call(pointerof(info), data).should eq(UIng::LibUI::DropAction::Copy)

    leaves = 0
    handler.leave { |_target| leaves += 1 }
    native.leave.call(data)
    handler.leave(nil)
    native.leave.call(data)
    leaves.should eq(1)
    handler.drop(nil)
    native.drop.call(Pointer(UIng::LibUI::DropInfo).null, Pointer(UIng::LibUI::DropData).null, data).should eq(UIng::LibUI::DropResult::Rejected)
  ensure
    window.try &.destroy
  end

  it "preserves the current handler on failure and clears it on destruction" do
    window = DropWindowForSpec.new
    handler = UIng::Drop::Handler.new { drop { |_target, _event| true } }
    other = UIng::Drop::Handler.new { drop { |_target, _event| false } }
    window.drop_handler = handler
    window.status = UIng::LibUI::DropStatus::NativeError
    error = expect_raises(UIng::Drop::Error) { window.drop_handler = other }
    error.status.should eq(UIng::LibUI::DropStatus::NativeError)
    window.drop_handler.should be(handler)
    expect_raises(UIng::Drop::Error) { window.clear_drop_handler }
    window.drop_handler.should be(handler)

    window.status = UIng::LibUI::DropStatus::OK
    window.drop_handler = other
    window.drop_handler.should be(other)
    window.drop_handler = nil
    window.drop_handler.should be_nil
    window.clear_drop_handler
    window.drop_handler = handler
    window.destroy
    expect_raises(Exception, /destroyed/) { window.drop_handler = handler }
    expect_raises(Exception, /destroyed/) { window.clear_drop_handler }
  ensure
    window.try &.destroy
  end

  it "supports shared handlers and self-removal while a callback is running" do
    first = DropWindowForSpec.new
    second = DropWindowForSpec.new
    calls = 0
    targets = [] of UIng::Control
    handler = UIng::Drop::Handler.new do
      drop do |target, _event|
        targets << target
        target.clear_drop_handler
        GC.collect
        calls += 1
        true
      end
    end
    first.drop_handler = handler
    second.drop_handler = handler
    info = UIng::LibUI::DropInfo.new(format: UIng::LibUI::DropFormat::Text)
    text = ""
    payload = UIng::LibUI::DropData.new(format: UIng::LibUI::DropFormat::Text, text: text.to_unsafe)
    first.native_handler.drop.call(pointerof(info), pointerof(payload), first.user_data).should eq(UIng::LibUI::DropResult::Accepted)
    first.drop_handler.should be_nil
    second.drop_handler.should be(handler)
    second.native_handler.drop.call(pointerof(info), pointerof(payload), second.user_data).should eq(UIng::LibUI::DropResult::Accepted)
    second.drop_handler.should be_nil
    calls.should eq(2)
    handler.drop do |target, event|
      targets << target
      target.destroy
      GC.collect
      event.text == ""
    end
    second.drop_handler = handler
    second.native_handler.drop.call(pointerof(info), pointerof(payload), second.user_data).should eq(UIng::LibUI::DropResult::Accepted)
    targets.should eq([first, second, second])
  ensure
    first.try &.destroy
    second.try &.destroy
  end

  it "keeps the executing callback and its target stable during replacement" do
    window = DropWindowForSpec.new
    calls = [] of String
    replacement = UIng::Drop::Handler.new do
      drop { |target, _event| calls << "new"; target.clear_drop_handler; true }
    end
    window.drop_handler = UIng::Drop::Handler.new do
      drop do |target, _event|
        target.drop_handler = replacement
        GC.collect
        calls << "old"
        true
      end
    end
    info = UIng::LibUI::DropInfo.new(format: UIng::LibUI::DropFormat::Text)
    payload = UIng::LibUI::DropData.new(format: UIng::LibUI::DropFormat::Text, text: "".to_unsafe)
    window.native_handler.drop.call(pointerof(info), pointerof(payload), window.user_data).should eq(UIng::LibUI::DropResult::Accepted)
    window.drop_handler.should be(replacement)
    window.native_handler.drop.call(pointerof(info), pointerof(payload), window.user_data).should eq(UIng::LibUI::DropResult::Accepted)
    calls.should eq(["old", "new"])
  ensure
    window.try &.destroy
  end

  it "rejects missing drop callbacks and invalid accepted formats" do
    expect_raises(ArgumentError) { UIng::Drop::Handler.new(accepts: :none) }
    expect_raises(ArgumentError) { UIng::Drop::Handler.new(accepts: UIng::Drop::Format.new(4_u32)) }
    window = DropWindowForSpec.new
    expect_raises(ArgumentError, /drop callback/) { window.drop_handler = UIng::Drop::Handler.new }
    window.drop_handler.should be_nil
  ensure
    window.try &.destroy
  end

  it "reports callback errors and returns rejection without unwinding into C" do
    window = DropWindowForSpec.new
    handler = UIng::Drop::Handler.new do
      drop { |_target, _event| raise "drop failed" }
      over { |_target, _info| raise "over failed" }
      leave { |_target| raise "leave failed" }
    end
    window.drop_handler = handler
    errors = [] of String
    UIng.on_error { |_error, context| errors << context }
    info = UIng::LibUI::DropInfo.new(format: UIng::LibUI::DropFormat::Text)
    payload = UIng::LibUI::DropData.new(format: UIng::LibUI::DropFormat::Text, text: "".to_unsafe)
    native = window.native_handler
    data = window.user_data
    UIng.expect_callback_error_log("drop failed", "Drop drop") do
      native.drop.call(pointerof(info), pointerof(payload), data).should eq(UIng::LibUI::DropResult::Rejected)
    end
    UIng.expect_callback_error_log("over failed", "Drop over") do
      native.over.call(pointerof(info), data).should eq(UIng::LibUI::DropAction::None)
    end
    UIng.expect_callback_error_log("leave failed", "Drop leave") { native.leave.call(data) }
    errors.should eq(["Drop drop", "Drop over", "Drop leave"])
  ensure
    UIng.on_error(nil)
    window.try &.destroy
  end
end
