require "../../spec_helper"
require "../../support/native_wrappers"

describe UIng::Area::ScrollEvent do
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
end
