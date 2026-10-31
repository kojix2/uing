require "../spec_helper"

private class UnallocatedMultilineEntry < UIng::MultilineEntry
  def initialize
    @ref_ptr = Pointer(UIng::LibUI::MultilineEntry).null
  end
end

describe UIng::MultilineEntry do
  it "rejects invalid font sizes before accessing the native control" do
    entry = UnallocatedMultilineEntry.new

    [0, -1, Float64::NAN, Float64::INFINITY, -Float64::INFINITY].each do |size|
      expect_raises(ArgumentError, /finite and positive/) { entry.font_size = size }
    end
  end
end
