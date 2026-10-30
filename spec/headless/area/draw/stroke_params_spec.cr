require "../../../spec_helper"

describe UIng::Area::Draw::StrokeParams do
  it "synchronizes dash values with its native structure" do
    params = UIng::Area::Draw::StrokeParams.new(
      cap: UIng::Area::Draw::LineCap::Round,
      join: UIng::Area::Draw::LineJoin::Bevel,
      thickness: 2,
      dash_phase: 0.5,
      dashes: [1, 3.0]
    )
    native = params.to_unsafe.value

    params.num_dashes.should eq(2)
    {native.dashes[0], native.dashes[1]}.should eq({1.0, 3.0})
    {params.thickness, params.dash_phase}.should eq({2.0, 0.5})
    {params.cap, params.join}.should eq({UIng::Area::Draw::LineCap::Round, UIng::Area::Draw::LineJoin::Bevel})

    float_dashes = [2.0, 4.0]
    params.dashes = float_dashes
    params.dashes.should be(float_dashes)
  end
end
