require "../../../../spec_helper"

describe UIng::Area::Draw::Brush::GradientStop do
  it "converts accepted Number inputs to Float64" do
    stop = UIng::Area::Draw::Brush::GradientStop.new(pos: 0, r: 1, g: 0, b: 1, a: 1)

    {stop.pos, stop.r}.should eq({0.0, 1.0})
  end

  it "accepts integer and floating-point drawing values" do
    stop = UIng::Area::Draw::Brush::GradientStop.new(pos: 0)
    stop.pos = 0.5
    stop.r = 1

    {stop.pos, stop.r}.should eq({0.5, 1.0})
  end

  it "rejects positions outside normalized ranges" do
    expect_raises(ArgumentError, /gradient stop position must be finite and between 0 and 1/) do
      UIng::Area::Draw::Brush::GradientStop.new(pos: 1.01)
    end
  end
end
