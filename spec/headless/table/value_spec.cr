require "../../spec_helper"

describe UIng::Table::Value do
  it "rejects color components outside normalized ranges before calling libui-ng" do
    expect_raises(ArgumentError, /table color blue must be finite and between 0 and 1/) do
      UIng::Table::Value.new_color(0, 0, 2, 1)
    end
  end
end
