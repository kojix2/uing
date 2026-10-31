require "../spec_helper"

private class UnallocatedColorButton < UIng::ColorButton
  def initialize
    @ref_ptr = Pointer(UIng::LibUI::ColorButton).null
  end
end

describe UIng::ColorButton do
  it "rejects invalid components before accessing the native control" do
    button = UnallocatedColorButton.new

    [-0.1, 1.1, Float64::NAN, Float64::INFINITY, -Float64::INFINITY].each do |value|
      expect_raises(ArgumentError, /color button red/) { button.set_color(value, 0, 0, 1) }
      expect_raises(ArgumentError, /color button green/) { button.set_color(0, value, 0, 1) }
      expect_raises(ArgumentError, /color button blue/) { button.set_color(0, 0, value, 1) }
      expect_raises(ArgumentError, /color button alpha/) { button.set_color(0, 0, 0, value) }
    end
  end
end
