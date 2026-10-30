require "../../../spec_helper"
require "../../../support/native_wrappers"

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

describe UIng::Area::Draw::Path do
  it "rejects non-finite coordinates and arc radii before calling libui-ng" do
    path = UIng::Area::Draw::Path.from_native_for_spec(Pointer(UIng::LibUI::DrawPath).null)

    expect_raises(ArgumentError, /path y must be finite/) do
      path.new_figure(0, Float64::INFINITY)
    end
    expect_raises(ArgumentError, /path arc radius must be finite/) do
      path.arc_to(0, 0, Float64::NAN, 0, Math::PI, false)
    end
  end

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

  it "rejects invalid rounded rectangle geometry before calling libui-ng" do
    path = UIng::Area::Draw::Path.from_native_for_spec(Pointer(UIng::LibUI::DrawPath).null)

    expect_raises(ArgumentError, /x must be finite/) { path.add_rounded_rectangle(Float64::NAN, 0, 1, 1, 1) }
    expect_raises(ArgumentError, /width must be nonnegative/) { path.add_rounded_rectangle(0, 0, -1, 1, 1) }
    expect_raises(ArgumentError, /height must be nonnegative/) { path.add_rounded_rectangle(0, 0, 1, -1, 1) }
    expect_raises(ArgumentError, /radius must be nonnegative/) { path.add_rounded_rectangle(0, 0, 1, 1, -1) }
    expect_raises(ArgumentError, /radius must be finite/) { path.add_rounded_rectangle(0, 0, 1, 1, Float64::INFINITY) }
  end
end
