require "./spec_helper"

private class CallbackAreaForSpec < UIng::Area
  def initialize(handler : Handler = Handler.new, owns_handler : Bool = true)
    @area_handler = handler
    @owns_handler = owns_handler
    @ref_ptr = Pointer(UIng::LibUI::Area).null
  end

  def handler_ptr : UIng::LibUI::AreaHandler*
    @area_handler.not_nil!.to_unsafe
  end

  def retains_handler? : Bool
    !@area_handler.nil?
  end

  def release_for_spec : Nil
    mark_destroyed_from_native
  end
end

describe "Area event wrappers" do
  it "dispatches per-Area callbacks and releases them after destruction" do
    area = CallbackAreaForSpec.new
    draws = [] of Float64
    mouse_x = [] of Float64
    crossed = [] of Bool
    broken = 0
    area.on_draw { |params| draws << params.area_width }
    area.on_mouse_event { |event| mouse_x << event.x }
    area.on_mouse_crossed { |left| crossed << left }
    area.on_drag_broken { broken += 1 }
    area.on_key_event { |event| !event.up? }
    area.on_scroll_event { |event| event.delta_y > 0 }
    GC.collect

    handler_ptr = area.handler_ptr
    area_ptr = Pointer(UIng::LibUI::Area).null
    draw_params = UIng::LibUI::AreaDrawParams.new(area_width: 240.0)
    mouse_event = UIng::LibUI::AreaMouseEvent.new(x: 12.0)
    key_event = UIng::LibUI::AreaKeyEvent.new(up: 0)
    scroll_event = UIng::LibUI::AreaScrollEvent.new(delta_y: 1.0)

    handler_ptr.value.draw.call(handler_ptr, area_ptr, pointerof(draw_params))
    handler_ptr.value.mouse_event.call(handler_ptr, area_ptr, pointerof(mouse_event))
    handler_ptr.value.mouse_crossed.call(handler_ptr, area_ptr, 1)
    handler_ptr.value.drag_broken.call(handler_ptr, area_ptr)
    handler_ptr.value.key_event.call(handler_ptr, area_ptr, pointerof(key_event)).should eq(1)
    handler_ptr.value.scroll_event.call(handler_ptr, area_ptr, pointerof(scroll_event)).should eq(1)
    draws.should eq([240.0])
    mouse_x.should eq([12.0])
    crossed.should eq([true])
    broken.should eq(1)

    area.on_draw(nil)
    area.clear_on_mouse_event
    area.on_mouse_crossed(nil)
    area.clear_on_drag_broken
    area.on_key_event(nil)
    area.clear_on_scroll_event
    handler_ptr.value.draw.call(handler_ptr, area_ptr, pointerof(draw_params))
    handler_ptr.value.mouse_event.call(handler_ptr, area_ptr, pointerof(mouse_event))
    handler_ptr.value.mouse_crossed.call(handler_ptr, area_ptr, 0)
    handler_ptr.value.drag_broken.call(handler_ptr, area_ptr)
    handler_ptr.value.key_event.call(handler_ptr, area_ptr, pointerof(key_event)).should eq(0)
    handler_ptr.value.scroll_event.pointer.null?.should be_true
    draws.should eq([240.0])
    mouse_x.should eq([12.0])
    crossed.should eq([true])
    broken.should eq(1)

    area.release_for_spec
    area.retains_handler?.should be_false
    expect_raises(Exception, /already been destroyed/) { area.on_draw { |_params| } }
  end

  it "keeps shared Handler callbacks separate from per-Area registration" do
    handler = UIng::Area::Handler.new
    first = CallbackAreaForSpec.new(handler, owns_handler: false)
    second = CallbackAreaForSpec.new(handler, owns_handler: false)
    calls = 0
    handler.draw { |_area, _params| calls += 1 }

    expect_raises(ArgumentError, /without an explicit Handler/) do
      first.on_draw { |_params| }
    end
    expect_raises(ArgumentError, /without an explicit Handler/) do
      second.on_mouse_event { |_event| }
    end

    first.release_for_spec
    first.retains_handler?.should be_false
    GC.collect
    handler_ptr = second.handler_ptr
    draw_params = UIng::LibUI::AreaDrawParams.new
    handler_ptr.value.draw.call(handler_ptr, Pointer(UIng::LibUI::Area).null, pointerof(draw_params))
    calls.should eq(1)
    second.release_for_spec
  end

  it "copies scroll event values from the native callback structure" do
    native = UIng::LibUI::AreaScrollEvent.new(
      x: 12.5,
      y: 7.25,
      delta_x: -0.5,
      delta_y: 1.25,
      modifiers: UIng::Area::Modifiers::Shift
    )
    event = UIng::Area::ScrollEvent.from_native_for_spec(pointerof(native))
    native.delta_y = 10.0

    {event.x, event.y, event.delta_x, event.delta_y}.should eq({12.5, 7.25, -0.5, 1.25})
    event.modifiers.should eq(UIng::Area::Modifiers::Shift)
  end

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
    event = UIng::Area::MouseEvent.from_native_for_spec(pointerof(native))
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
    event = UIng::Area::KeyEvent.from_native_for_spec(pointerof(native))
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
    extended_event = UIng::Area::KeyEvent.from_native_for_spec(pointerof(extended_native))
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

  it "converts scroll callback results and stops invoking a cleared callback" do
    handler = UIng::Area::Handler.new
    handler.to_unsafe.value.scroll_event.pointer.null?.should be_true
    received = [] of Tuple(Float64, Float64)
    handler.scroll_event do |_area, event|
      received << {event.delta_x, event.delta_y}
      event.delta_y > 0
    end
    handler_ptr = handler.to_unsafe
    area_ptr = Pointer(UIng::LibUI::Area).null
    scroll_event = UIng::LibUI::AreaScrollEvent.new(delta_x: -0.5, delta_y: 1.25)

    handled = handler_ptr.value.scroll_event.call(handler_ptr, area_ptr, pointerof(scroll_event))
    scroll_event.delta_y = -1.25
    unhandled = handler_ptr.value.scroll_event.call(handler_ptr, area_ptr, pointerof(scroll_event))
    handler.scroll_event(nil)

    received.should eq([{-0.5, 1.25}, {-0.5, -1.25}])
    {handled, unhandled}.should eq({1, 0})
    handler_ptr.value.scroll_event.pointer.null?.should be_true
  end

  it "stops invoking cleared Area callbacks through the native handler" do
    handler = UIng::Area::Handler.new
    crossed = false
    handler.mouse_crossed { |_area, _left| crossed = true }
    handler.key_event { |_area, _event| true }

    handler.clear_mouse_crossed
    handler.key_event(nil)
    handler_ptr = handler.to_unsafe
    area_ptr = Pointer(UIng::LibUI::Area).null
    key_event = UIng::LibUI::AreaKeyEvent.new

    handler_ptr.value.mouse_crossed.call(handler_ptr, area_ptr, 1)
    handled = handler_ptr.value.key_event.call(handler_ptr, area_ptr, pointerof(key_event))

    crossed.should be_false
    handled.should eq(0)
  end
end
