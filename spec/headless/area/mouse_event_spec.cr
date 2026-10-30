require "../../spec_helper"
require "../../support/native_wrappers"

describe UIng::Area::MouseEvent do
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
end
