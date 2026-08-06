require "./spec_helper"

private class LifetimeControl < UIng::Control
  @ref_ptr : Pointer(UIng::LibUI::Button)

  def initialize
    @ref_ptr = Pointer(UIng::LibUI::Button).null
  end

  def adopt(parent : UIng::Control) : Nil
    take_ownership(parent)
  end

  def mark_from_parent_destroy : Nil
    mark_released_from_parent_destroy
  end

  def mark_from_native_destroy : Nil
    mark_released_from_native_destroy
  end

  def to_unsafe
    ref_ptr
  end
end

private class LifetimeContainer < LifetimeControl
  @child : UIng::Control?

  def initialize(@child : UIng::Control? = nil)
    super()
  end

  def adopt_child(child : LifetimeControl) : Nil
    @child = child
    child.adopt(self)
  end

  protected def before_destroy : Nil
    @child.try &.mark_released_from_parent_destroy
    @child = nil
  end
end

describe UIng::Control do
  it "marks descendants released when a parent is destroyed natively" do
    parent = LifetimeContainer.new
    child = LifetimeContainer.new
    grandchild = LifetimeControl.new

    parent.adopt_child(child)
    child.adopt_child(grandchild)
    parent.mark_from_parent_destroy

    parent.released?.should be_true
    child.released?.should be_true
    grandchild.released?.should be_true
    child.parent.should be_nil
    grandchild.parent.should be_nil
  end

  it "rejects direct destroy while the control is owned by a parent" do
    parent = LifetimeContainer.new
    child = LifetimeControl.new
    parent.adopt_child(child)

    expect_raises(Exception, /destroy a child control directly/) do
      child.destroy
    end

    child.released?.should be_false
    child.parent.should eq(parent)
  end

  it "rejects checked pointer access after parent destroy marking" do
    child = LifetimeControl.new
    child.mark_from_parent_destroy

    expect_raises(Exception, /already been destroyed/) do
      child.to_unsafe
    end
  end

  it "marks descendants released when native code destroys a root control" do
    root = LifetimeContainer.new
    child = LifetimeControl.new
    root.adopt_child(child)

    root.mark_from_native_destroy

    root.released?.should be_true
    child.released?.should be_true
    child.parent.should be_nil
  end
end
