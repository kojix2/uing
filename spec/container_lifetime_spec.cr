require "./spec_helper"

private class DetachableControl < UIng::Control
  @ref_ptr : Pointer(UIng::LibUI::Button)

  def initialize
    @ref_ptr = Pointer(UIng::LibUI::Button).new(0x200_u64)
  end

  def adopt(parent : UIng::Control) : Nil
    take_ownership(parent)
  end

  def to_unsafe
    ref_ptr
  end
end

private class DetachableWindow < UIng::Window
  getter native_child_cleared = false

  def initialize
    @ref_ptr = Pointer(UIng::LibUI::Window).null
  end

  protected def set_native_child(child : Pointer(UIng::LibUI::Control)) : Nil
    @native_child_cleared = child.null?
  end

  protected def destroy_native : Nil
  end
end

private class DetachableGroup < UIng::Group
  getter native_child_cleared = false

  def initialize
    @ref_ptr = Pointer(UIng::LibUI::Group).null
  end

  protected def set_native_child(child : Pointer(UIng::LibUI::Control)) : Nil
    @native_child_cleared = child.null?
  end

  protected def destroy_native : Nil
  end
end

private class DetachableGrid < UIng::Grid
  getter native_child_deleted = false

  def initialize
    @ref_ptr = Pointer(UIng::LibUI::Grid).null
  end

  def adopt(child : DetachableControl) : Nil
    @children_refs << child
    child.adopt(self)
  end

  protected def delete_native_child(child : UIng::Control) : Nil
    @native_child_deleted = true
  end
end

private class DetachableBox < UIng::Box
  getter native_child_deleted = false

  def initialize
    @ref_ptr = Pointer(UIng::LibUI::Box).null
  end

  def adopt(child : DetachableControl) : Nil
    @children_refs << child
    child.adopt(self)
  end

  protected def delete_native_child(index : Int32) : Nil
    @native_child_deleted = true
  end
end

private class DetachableForm < UIng::Form
  getter native_child_deleted = false

  def initialize
    @ref_ptr = Pointer(UIng::LibUI::Form).null
  end

  def adopt(child : DetachableControl) : Nil
    @children_refs << child
    child.adopt(self)
  end

  protected def delete_native_child(index : Int32) : Nil
    @native_child_deleted = true
  end
end

private class DetachableTab < UIng::Tab
  getter native_child_deleted = false

  def initialize
    @ref_ptr = Pointer(UIng::LibUI::Tab).null
  end

  def adopt(child : DetachableControl) : Nil
    @children_refs << child
    child.adopt(self)
  end

  protected def delete_native_child(index : Int32) : Nil
    @native_child_deleted = true
  end
end

private def verify_child_deletion(container : T) : Nil forall T
  child = DetachableControl.new
  container.adopt(child)

  child.detach

  child.parent.should be_nil
  container.native_child_deleted.should be_true
end

describe "container lifetime" do
  it "preserves Window ownership when child replacement is attempted while destruction is pending" do
    window = DetachableWindow.new
    old_child = DetachableControl.new
    new_child = DetachableControl.new
    window.child = old_child
    window.destroy

    expect_raises(Exception, /already been destroyed/) do
      window.child = new_child
    end

    window.child.should be(old_child)
    old_child.parent.should be(window)
    new_child.parent.should be_nil
  end

  it "preserves Group ownership when child replacement is attempted while destruction is pending" do
    group = DetachableGroup.new
    old_child = DetachableControl.new
    new_child = DetachableControl.new
    group.child = old_child
    group.destroy

    expect_raises(Exception, /already been destroyed/) do
      group.child = new_child
    end

    group.child.should be(old_child)
    old_child.parent.should be(group)
    new_child.parent.should be_nil
  end

  it "clears and detaches a Window child" do
    window = DetachableWindow.new
    child = DetachableControl.new
    window.child = child

    window.child.should be(child)
    child.detach

    window.child.should be_nil
    child.parent.should be_nil
    window.native_child_cleared.should be_true
  end

  it "clears and detaches a Group child" do
    group = DetachableGroup.new
    child = DetachableControl.new
    group.child = child

    group.child.should be(child)
    group.child = nil

    group.child.should be_nil
    child.parent.should be_nil
    group.native_child_cleared.should be_true
  end

  it "detaches a Grid child through uiGridDelete" do
    grid = DetachableGrid.new
    child = DetachableControl.new
    grid.adopt(child)

    child.detach

    child.parent.should be_nil
    grid.native_child_deleted.should be_true
  end

  it "preserves Box, Form, and Tab child deletion semantics" do
    verify_child_deletion(DetachableBox.new)
    verify_child_deletion(DetachableForm.new)
    verify_child_deletion(DetachableTab.new)
  end
end
