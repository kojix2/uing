require "../spec_helper"

private class CallbackAreaForSpec < UIng::Area
  def initialize(handler : Handler = Handler.new, owns_handler : Bool = true)
    @area_handler = handler
    @owns_handler = owns_handler
    @ref_ptr = Pointer(UIng::LibUI::Area).null
  end

  def handler_ptr : UIng::LibUI::AreaHandler*
    handler = @area_handler || raise "Area Handler is unavailable"
    handler.to_unsafe
  end

  def retains_handler? : Bool
    !@area_handler.nil?
  end

  def release_for_spec : Nil
    mark_destroyed_from_native
  end
end

describe UIng::Area do
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
end
