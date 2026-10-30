require "../spec_helper"
require "../support/menu_items"

class UIng::MenuItem
  def self.item_for_spec(kind : Symbol) : MenuItem
    __new_for_menu__(Pointer(UIng::LibUI::MenuItem).null, kind)
  end

  def self.quit_item_for_spec : MenuItem
    item_for_spec(:quit)
  end
end

private class ShortcutSpecMenuItem < UIng::MenuItem
  def initialize
    super(Pointer(UIng::LibUI::MenuItem).null)
  end
end

describe UIng::MenuItem do
  it "clears a MenuItem click callback without invalidating its wrapper" do
    item = SpecSupport::LifetimeSafetyMenuItem.new

    item.clear_on_clicked

    item.callback_clear_count.should eq(1)
    item.callback_was_retained_when_cleared?.should be_true
    item.callback_retained?.should be_false
    item.to_unsafe.null?.should be_true

    item.on_clicked(nil)
    item.callback_clear_count.should eq(1)
  end

  it "does not touch the native callback when a MenuItem has no registered callback" do
    item = SpecSupport::LifetimeSafetyMenuItem.new(callback_registered: false)

    item.clear_on_clicked

    item.callback_clear_count.should eq(0)
    item.to_unsafe.null?.should be_true
  end

  it "rejects callbacks on Quit MenuItems before calling libui-ng" do
    item = UIng::MenuItem.quit_item_for_spec

    expect_raises(ArgumentError, /UIng\.on_should_quit/) do
      item.on_clicked { |_window| }
    end

    item.clear_on_clicked
    item.to_unsafe.null?.should be_true
  end

  it "rejects checked state on non-check MenuItems before calling libui-ng" do
    [:regular, :quit, :preferences, :about].each do |kind|
      item = UIng::MenuItem.item_for_spec(kind)

      expect_raises(ArgumentError, /only available for check MenuItems/) { item.checked? }
      expect_raises(ArgumentError, /only available for check MenuItems/) { item.checked = true }
    end
  end

  it "rejects unsupported shortcut keys before calling libui-ng" do
    item = ShortcutSpecMenuItem.new
    expect_raises(ArgumentError, /ASCII letter or digit/) { item.set_shortcut('é', UIng::Modifiers::Primary) }
    expect_raises(ArgumentError, /unsupported extended/) { item.set_shortcut(UIng::ExtKey::Escape, UIng::Modifiers::Primary) }
    expect_raises(ArgumentError, /unsupported extended/) { item.set_shortcut(UIng::ExtKey::N1, UIng::Modifiers::Primary) }
    expect_raises(ArgumentError, /unsupported extended/) { item.set_shortcut(UIng::ExtKey.new(0), UIng::Modifiers::Primary) }
  end

  it "rejects unsupported modifier combinations before calling libui-ng" do
    item = ShortcutSpecMenuItem.new
    expect_raises(ArgumentError, /only Primary, Ctrl, Alt, and Shift/) { item.set_shortcut('O', UIng::Modifiers::Super) }
    expect_raises(ArgumentError, /only Primary, Ctrl, Alt, and Shift/) { item.set_shortcut('O', UIng::Modifiers.new(1 << 5)) }
    expect_raises(ArgumentError, /Primary and Ctrl/) { item.set_shortcut('O', UIng::Modifiers::Primary | UIng::Modifiers::Ctrl) }
    expect_raises(ArgumentError, /requires Primary, Ctrl, or Alt/) { item.set_shortcut('O', UIng::Modifiers::Shift) }
    expect_raises(ArgumentError, /requires Primary, Ctrl, or Alt/) { item.set_shortcut(UIng::ExtKey::Delete) }
  end
end
