require "./spec_helper"

describe "Area event wrappers" do
  it "copies mouse event values from the native callback structure" do
    native = UIng::LibUI::AreaMouseEvent.new(
      x: 12.5,
      y: 7.25,
      area_width: 320.0,
      area_height: 200.0,
      down: 1,
      up: 0,
      count: 2,
      modifiers: UIng::Area::Modifiers::Ctrl | UIng::Area::Modifiers::Shift,
      held1_to64: 5_u64
    )
    event = UIng::Area::MouseEvent.new(pointerof(native))
    native.x = 99.0

    {event.x, event.y}.should eq({12.5, 7.25})
    {event.area_width, event.area_height}.should eq({320.0, 200.0})
    {event.down, event.up, event.count}.should eq({1, 0, 2})
    event.modifiers.should eq(UIng::Area::Modifiers::Ctrl | UIng::Area::Modifiers::Shift)
    event.held1_to64.should eq(5_u64)
  end

  it "copies key event values from the native callback structure" do
    native = UIng::LibUI::AreaKeyEvent.new(
      key: 'x'.ord.to_i8,
      ext_key: UIng::Area::ExtKey.new(0),
      modifier: UIng::Area::Modifiers::Ctrl,
      modifiers: UIng::Area::Modifiers::Ctrl | UIng::Area::Modifiers::Alt,
      up: 1
    )
    event = UIng::Area::KeyEvent.new(pointerof(native))
    native.key = 'z'.ord.to_i8

    event.key.should eq('x')
    event.ext_key.should be_nil
    event.modifier.should eq(UIng::Area::Modifiers::Ctrl)
    event.modifiers.should eq(UIng::Area::Modifiers::Ctrl | UIng::Area::Modifiers::Alt)
    event.up?.should be_true

    extended_native = UIng::LibUI::AreaKeyEvent.new(
      key: 0_i8,
      ext_key: UIng::Area::ExtKey::F2,
      up: 0
    )
    extended_event = UIng::Area::KeyEvent.new(pointerof(extended_native))
    extended_event.key.should be_nil
    extended_event.ext_key.should eq(UIng::Area::ExtKey::F2)
    extended_event.up?.should be_false
  end

  it "converts integer callback flags at the Area handler boundary" do
    crossed = [] of Bool
    handler = UIng::Area::Handler.new
    handler.mouse_crossed { |_area, left| crossed << left }
    handler.key_event { |_area, event| !event.up? }
    handler_ptr = handler.to_unsafe
    area_ptr = Pointer(UIng::LibUI::Area).null

    handler_ptr.value.mouse_crossed.call(handler_ptr, area_ptr, 0)
    handler_ptr.value.mouse_crossed.call(handler_ptr, area_ptr, 2)

    key_event = UIng::LibUI::AreaKeyEvent.new(up: 0)
    handled = handler_ptr.value.key_event.call(handler_ptr, area_ptr, pointerof(key_event))
    key_event.up = 1
    unhandled = handler_ptr.value.key_event.call(handler_ptr, area_ptr, pointerof(key_event))

    crossed.should eq([false, true])
    {handled, unhandled}.should eq({1, 0})
  end
end
