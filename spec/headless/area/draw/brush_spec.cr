require "../../../spec_helper"

describe UIng::Area::Draw::Brush do
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

  it "supports block construction without replacing the instance" do
    yielded = nil
    brush = UIng::Area::Draw::Brush.new(UIng::Area::Draw::Brush::Type::Solid) do |instance|
      yielded = instance
      instance.r = 0.4
    end

    yielded.should be(brush)
    brush.r.should eq(0.4)
  end
end
