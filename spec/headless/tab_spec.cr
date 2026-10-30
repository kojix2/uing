require "../spec_helper"
require "../support/containers"

private def verify_invalid_tab_page_index(tab : SpecSupport::DetachableTab, index : Int32) : Nil
  expect_raises(IndexError) { tab.margined?(index) }
  expect_raises(IndexError) { tab.set_margined(index, true) }
end

describe UIng::Tab do
  it "rejects invalid Tab insertion indices without changing ownership" do
    tab = SpecSupport::DetachableTab.new
    first_child = SpecSupport::DetachableControl.new
    second_child = SpecSupport::DetachableControl.new
    tab.adopt(first_child)
    tab.adopt(second_child)
    expected_children = [first_child, second_child] of UIng::Control

    [-1, 3].each do |index|
      inserted_child = SpecSupport::DetachableControl.new
      expect_raises(IndexError) { tab.insert_at("invalid", index, inserted_child) }

      tab.child_refs.should eq(expected_children)
      inserted_child.parent.should be_nil
    end

    empty_tab = SpecSupport::DetachableTab.new
    [-1, 1].each do |index|
      inserted_child = SpecSupport::DetachableControl.new
      expect_raises(IndexError) { empty_tab.insert_at("invalid", index, inserted_child) }

      empty_tab.child_refs.should be_empty
      inserted_child.parent.should be_nil
    end
  end

  it "preserves Tab insertion validation through the block DSL" do
    tab = SpecSupport::DetachableTab.new
    existing = SpecSupport::DetachableControl.new
    tab.adopt(existing)

    [-1, 2].each do |index|
      child = SpecSupport::DetachableControl.new
      expect_raises(IndexError) { tab.insert_at("invalid", index, margined: true) { child } }

      child.parent.should be_nil
      tab.child_refs.should eq([existing])
    end
    existing.parent.should be(tab)
  end

  it "rejects invalid Tab margin indices" do
    tab = SpecSupport::DetachableTab.new
    tab.adopt(SpecSupport::DetachableControl.new)
    tab.adopt(SpecSupport::DetachableControl.new)
    [-1, -2, -3, 2].each { |index| verify_invalid_tab_page_index(tab, index) }

    empty_tab = SpecSupport::DetachableTab.new
    [-1, 0].each { |index| verify_invalid_tab_page_index(empty_tab, index) }
  end
end
