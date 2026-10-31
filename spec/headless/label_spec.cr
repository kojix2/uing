require "../spec_helper"

private class UnallocatedLabel < UIng::Label
  def initialize
    @ref_ptr = Pointer(UIng::LibUI::Label).null
  end
end

describe UIng::Label do
  it "rejects invalid font sizes before accessing the native control" do
    label = UnallocatedLabel.new

    [0, -1, Float64::NAN, Float64::INFINITY, -Float64::INFINITY].each do |size|
      expect_raises(ArgumentError, /finite and positive/) { label.font_size = size }
    end
  end
end
