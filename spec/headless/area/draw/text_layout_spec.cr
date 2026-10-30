require "../../../spec_helper"

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

describe UIng::Area::Draw::TextLayout do
  it "infers the return type of TextLayout.open from its block" do
    result_type = typeof(UIng::Area::Draw::TextLayout.open(
      UIng::Area::AttributedString.new("abc"),
      UIng::FontDescriptor.new,
      10
    ) { |layout| layout.extents })

    result_type.should eq(Tuple(Float64, Float64))
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
