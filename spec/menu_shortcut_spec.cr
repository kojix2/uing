require "./spec_helper"

private class ShortcutSpecMenuItem < UIng::MenuItem
  def initialize
    super(Pointer(UIng::LibUI::MenuItem).null)
  end
end

describe UIng::MenuItem do
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

if ENV["UING_NATIVE_GUI_TESTS"]? == "1"
  describe "native menu shortcuts" do
    it "sets and clears letter and extended-key shortcuts" do
      UIng.init
      menu = UIng::Menu.new("File")
      item = menu.append_item("Open")
      item.set_shortcut('o', UIng::Modifiers::Primary)
      item.clear_shortcut
      item.set_shortcut(UIng::ExtKey::F1)
    ensure
      UIng.uninit
    end
  end
end
