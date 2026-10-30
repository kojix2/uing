require "../../../spec_helper"

describe UIng::Area::Draw::Brush do
  it "accepts integer and floating-point drawing values" do
    stop = UIng::Area::Draw::Brush::GradientStop.new(pos: 0.5, r: 1)
    brush = UIng::Area::Draw::Brush.new(
      UIng::Area::Draw::Brush::Type::LinearGradient,
      x0: 0,
      x1: 10,
      stops: [stop]
    )
    brush.outer_radius = 4

    {brush.x1, brush.outer_radius}.should eq({10.0, 4.0})
  end

  it "supports block construction without replacing the instance" do
    yielded = nil
    brush = UIng::Area::Draw::Brush.new(UIng::Area::Draw::Brush::Type::Solid) do |instance|
      yielded = instance
      instance.r = 0.4
    end

    yielded.should be(brush)
    brush.r.should eq(0.4)
  end

  it "keeps an independent native gradient-stop buffer" do
    stop = UIng::Area::Draw::Brush::GradientStop.new(pos: 0.25, r: 0.5, g: 0.6, b: 0.7, a: 0.8)
    brush = UIng::Area::Draw::Brush.new(UIng::Area::Draw::Brush::Type::LinearGradient, stops: [stop])
    stop.pos = 0.9

    brush.num_stops.should eq(1)
    copied = brush.stops.first
    {copied.pos, copied.r, copied.g, copied.b, copied.a}.should eq({0.25, 0.5, 0.6, 0.7, 0.8})

    brush.stops = [] of UIng::Area::Draw::Brush::GradientStop
    brush.num_stops.should eq(0)
    brush.to_unsafe.value.stops.null?.should be_true
  end

  it "rejects color components outside normalized ranges" do
    expect_raises(ArgumentError, /brush red must be finite and between 0 and 1/) do
      UIng::Area::Draw::Brush.new(UIng::Area::Draw::Brush::Type::Solid, r: -0.01)
    end
  end
end
