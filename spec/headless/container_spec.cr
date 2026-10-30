require "../spec_helper"
require "../support/containers"

private class DetachableBox < UIng::Box
  getter native_delete_calls = 0
  getter native_deleted_index : Int32?

  def initialize
    @ref_ptr = Pointer(UIng::LibUI::Box).null
  end

  def adopt_by(parent : UIng::Control) : Nil
    take_ownership(parent)
  end

  def adopt(child : SpecSupport::DetachableControl) : Nil
    @children_refs << child
    child.adopt(self)
  end

  def child_refs : Array(UIng::Control)
    @children_refs.dup
  end

  protected def delete_native_child(index : Int32) : Nil
    @native_delete_calls += 1
    @native_deleted_index = index
  end
end

private class DetachableForm < UIng::Form
  getter native_delete_calls = 0
  getter native_deleted_index : Int32?

  def initialize
    @ref_ptr = Pointer(UIng::LibUI::Form).null
  end

  def adopt(child : SpecSupport::DetachableControl) : Nil
    @children_refs << child
    child.adopt(self)
  end

  def child_refs : Array(UIng::Control)
    @children_refs.dup
  end

  protected def delete_native_child(index : Int32) : Nil
    @native_delete_calls += 1
    @native_deleted_index = index
  end
end

private def verify_child_deletion(container : T) : Nil forall T
  child = SpecSupport::DetachableControl.new
  container.adopt(child)

  child.detach

  child.parent.should be_nil
  container.native_delete_calls.should eq(1)
  container.native_deleted_index.should eq(0)
end

private def verify_invalid_child_deletions(container : T, empty_container : T) : Nil forall T
  first_child = SpecSupport::DetachableControl.new
  second_child = SpecSupport::DetachableControl.new
  container.adopt(first_child)
  container.adopt(second_child)
  expected_children = [first_child, second_child] of UIng::Control

  [-1, -2, -3, 2].each do |index|
    expect_raises(IndexError) { container.delete(index) }

    container.native_delete_calls.should eq(0)
    container.child_refs.should eq(expected_children)
    first_child.parent.should be(container)
    second_child.parent.should be(container)
  end

  [-1, 0].each do |index|
    expect_raises(IndexError) { empty_container.delete(index) }

    empty_container.native_delete_calls.should eq(0)
    empty_container.child_refs.should be_empty
  end
end

describe "container ownership" do
  describe "attaching and detaching children" do
    it "preserves the set_child compatibility aliases" do
      window = SpecSupport::DetachableWindow.new
      window_child = SpecSupport::DetachableControl.new
      window.set_child(window_child)

      group = SpecSupport::DetachableGroup.new
      group_child = SpecSupport::DetachableControl.new
      group.set_child { group_child }

      window.child.should be(window_child)
      window_child.parent.should be(window)
      group.child.should be(group_child)
      group_child.parent.should be(group)
    end

    it "preserves Box, Form, and Tab child deletion semantics" do
      verify_child_deletion(DetachableBox.new)
      verify_child_deletion(DetachableForm.new)
      verify_child_deletion(SpecSupport::DetachableTab.new)
    end

    it "rejects invalid Box, Form, and Tab deletion indices without changing ownership" do
      verify_invalid_child_deletions(DetachableBox.new, DetachableBox.new)
      verify_invalid_child_deletions(DetachableForm.new, DetachableForm.new)
      verify_invalid_child_deletions(SpecSupport::DetachableTab.new, SpecSupport::DetachableTab.new)
    end
  end

  describe "attachment constraints" do
    it "rejects self-parenting before changing ownership" do
      box = DetachableBox.new

      expect_raises(Exception, /itself or one of its descendants/) do
        box.append(box)
      end

      box.parent.should be_nil
    end

    it "rejects control tree cycles before changing ownership" do
      outer = DetachableBox.new
      inner = DetachableBox.new
      inner.adopt_by(outer)

      expect_raises(Exception, /itself or one of its descendants/) do
        inner.append(outer)
      end

      outer.parent.should be_nil
      inner.parent.should be(outer)
    end

    it "rejects a top-level control as a child" do
      box = DetachableBox.new
      window = SpecSupport::DetachableWindow.new

      expect_raises(Exception, /top-level control/) do
        box.append(window)
      end

      window.parent.should be_nil
    end

    it "keeps containers unchanged when a child construction block raises" do
      grid = SpecSupport::DetachableGrid.new
      anchor = SpecSupport::DetachableControl.new
      grid.adopt(anchor)
      tab = SpecSupport::DetachableTab.new
      tab_child = SpecSupport::DetachableControl.new
      tab.adopt(tab_child)

      expect_raises(Exception, "child construction failed") do
        grid.append(left: 0, top: 0) { raise "child construction failed" }
      end
      expect_raises(Exception, "child construction failed") do
        grid.insert_at(anchor, :trailing) { raise "child construction failed" }
      end
      expect_raises(Exception, "child construction failed") do
        tab.insert_at("new", 1) { raise "child construction failed" }
      end

      anchor.parent.should be(grid)
      tab.child_refs.should eq([tab_child])
      tab_child.parent.should be(tab)
    end
  end
end
