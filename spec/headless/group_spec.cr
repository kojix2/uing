require "../spec_helper"
require "../support/containers"

describe UIng::Group do
  it "supports the Group child block DSL" do
    group = SpecSupport::DetachableGroup.new
    child = SpecSupport::DetachableControl.new

    group.child { child }

    group.child.should be(child)
    child.parent.should be(group)
  end

  it "clears and detaches a Group child" do
    group = SpecSupport::DetachableGroup.new
    child = SpecSupport::DetachableControl.new
    group.child = child

    group.child.should be(child)
    group.child = nil

    group.child.should be_nil
    child.parent.should be_nil
    group.native_child_cleared?.should be_true
  end

  it "preserves Group ownership when child replacement is attempted while destruction is pending" do
    group = SpecSupport::DetachableGroup.new
    old_child = SpecSupport::DetachableControl.new
    new_child = SpecSupport::DetachableControl.new
    group.child = old_child
    group.destroy

    expect_raises(Exception, /already been destroyed/) do
      group.child = new_child
    end

    group.child.should be(old_child)
    old_child.parent.should be(group)
    new_child.parent.should be_nil
  end
end
