require "../../spec_helper"

describe UIng::Area::Handler do
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
