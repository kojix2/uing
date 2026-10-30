require "../../spec_helper"

describe UIng::Area::Attribute do
  it "rejects non-finite color components before calling libui-ng" do
    expect_raises(ArgumentError, /text color alpha must be finite and between 0 and 1/) do
      UIng::Area::Attribute.new_color(0, 0, 0, Float64::NAN)
    end
  end
end
