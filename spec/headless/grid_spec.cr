require "../spec_helper"
require "../support/containers"

describe UIng::Grid do
  it "requires Grid insertion anchors to belong to the same Grid" do
    grid = SpecSupport::DetachableGrid.new
    child = SpecSupport::DetachableControl.new
    outsider = SpecSupport::DetachableControl.new

    expect_raises(ArgumentError, /does not belong to this Grid/) do
      grid.insert_at(child, outsider, UIng::Grid::At::Leading, 1, 1, false, UIng::Align::Fill, false, UIng::Align::Fill)
    end

    child.parent.should be_nil
  end

  it "rejects invalid Grid spans before passing them to libui-ng" do
    grid = SpecSupport::DetachableGrid.new
    anchor = SpecSupport::DetachableControl.new
    grid.adopt(anchor)
    child = SpecSupport::DetachableControl.new

    expect_raises(ArgumentError, /xspan must be at least 1/) do
      grid.append(child, 0, 0, 0, 1, false, UIng::Align::Fill, false, UIng::Align::Fill)
    end
    expect_raises(ArgumentError, /yspan must be at least 1/) do
      grid.insert_at(child, anchor, UIng::Grid::At::Trailing, yspan: 0)
    end

    child.parent.should be_nil
  end

  it "preserves Grid validation and ownership through the block DSL" do
    grid = SpecSupport::DetachableGrid.new
    anchor = SpecSupport::DetachableControl.new
    grid.adopt(anchor)
    child = SpecSupport::DetachableControl.new

    expect_raises(ArgumentError, /xspan must be at least 1/) do
      grid.append(left: 0, top: 0, xspan: 0) { child }
    end
    expect_raises(ArgumentError, /yspan must be at least 1/) do
      grid.insert_at(anchor, :trailing, yspan: 0) { child }
    end
    expect_raises(ArgumentError, /does not belong to this Grid/) do
      grid.insert_at(SpecSupport::DetachableControl.new, :leading) { child }
    end

    child.parent.should be_nil
    anchor.parent.should be(grid)
  end

  it "detaches a Grid child through uiGridDelete" do
    grid = SpecSupport::DetachableGrid.new
    child = SpecSupport::DetachableControl.new
    grid.adopt(child)

    child.detach

    child.parent.should be_nil
    grid.native_child_deleted?.should be_true
  end
end
