require "../../spec_helper"
require "../../support/native_wrappers"

describe UIng::Area::KeyEvent do
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
end
