require "./spec_helper"

private class ToolbarItemGuardToolbar < UIng::Toolbar
  def initialize
    @ref_ptr = Pointer(UIng::LibUI::Toolbar).null
  end
end

private class GuardedToolbarItem < UIng::ToolbarItem
  def initialize(toggle : Bool = false)
    super(
      ToolbarItemGuardToolbar.new,
      Pointer(UIng::LibUI::ToolbarItem).null,
      toggle: toggle
    )
  end
end

describe UIng::ToolbarItem do
  it "rejects reading checked state from a regular button before calling libui-ng" do
    item = GuardedToolbarItem.new

    expect_raises(ArgumentError, /only available for toggle ToolbarItems/) do
      item.checked?
    end
  end

  it "rejects setting checked state on a regular button before calling libui-ng" do
    item = GuardedToolbarItem.new

    expect_raises(ArgumentError, /only available for toggle ToolbarItems/) do
      item.checked = true
    end
  end

  it "reports a released item before checking its kind" do
    item = GuardedToolbarItem.new
    item.__release__

    expect_raises(Exception, /already been released/) do
      item.checked?
    end
  end
end
