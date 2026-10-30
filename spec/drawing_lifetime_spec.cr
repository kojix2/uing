require "./spec_helper"

private class BlockConstructionPath < UIng::Area::Draw::Path
  block_constructor
  getter free_calls = 0

  def initialize
    super(Pointer(UIng::LibUI::DrawPath).null)
  end

  def free : Nil
    @free_calls += 1
  end
end

private class BlockConstructionTextLayout < UIng::Area::Draw::TextLayout
  block_constructor
  getter free_calls = 0

  def initialize(*, width : Number)
    @ref_ptr = Pointer(UIng::LibUI::DrawTextLayout).null
  end

  def free : Nil
    @free_calls += 1
  end
end

describe "drawing block construction" do
  it "frees a Path on failure and preserves the original exception" do
    constructed = nil
    original = Exception.new("path construction failed")
    error = expect_raises(Exception, original.message) do
      BlockConstructionPath.new do |path|
        constructed = path
        raise original
      end
    end

    error.should be(original)
    constructed.should_not(be_nil).free_calls.should eq(1)
    BlockConstructionPath.new { }.free_calls.should eq(0)
  end

  it "frees a TextLayout created with keywords on failure" do
    constructed = nil
    original = Exception.new("layout construction failed")
    error = expect_raises(Exception, original.message) do
      BlockConstructionTextLayout.new(width: 100) do |layout|
        constructed = layout
        raise original
      end
    end

    error.should be(original)
    constructed.should_not(be_nil).free_calls.should eq(1)
    BlockConstructionTextLayout.new(width: 100) { }.free_calls.should eq(0)
  end
end
