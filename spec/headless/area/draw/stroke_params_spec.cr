require "../../../spec_helper"

describe UIng::Area::Draw::StrokeParams do
  it "converts accepted Number inputs to Float64" do
    params = UIng::Area::Draw::StrokeParams.new(thickness: 2, dash_phase: -1)

    {params.thickness, params.dash_phase}.should eq({2.0, -1.0})
  end

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

  it "rejects zero thickness" do
    expect_raises(ArgumentError, /stroke thickness must be finite and positive/) do
      UIng::Area::Draw::StrokeParams.new(thickness: 0)
    end
  end

  it "accepts zero-length segments and an empty pattern for solid lines" do
    params = UIng::Area::Draw::StrokeParams.new(dashes: [0, 3, 0])
    native = params.to_unsafe.value
    {native.dashes[0], native.dashes[1], native.dashes[2]}.should eq({0.0, 3.0, 0.0})

    params.dashes = [] of Float64
    native = params.to_unsafe.value
    native.num_dashes.should eq(0)
    native.dashes.null?.should be_true
  end

  it "rejects negative, non-finite, and all-zero patterns during construction" do
    [[-1.0, 1.0], [0.0, 0.0], [Float64::NAN], [Float64::INFINITY], [-1, 2], [0, 0]].each do |values|
      expect_raises(ArgumentError, /stroke dash/) do
        UIng::Area::Draw::StrokeParams.new(dashes: values)
      end
    end
  end

  it "preserves the previous pattern when either setter rejects a replacement" do
    params = UIng::Area::Draw::StrokeParams.new(dashes: [2, 4])
    [[-1.0, 1.0], [0.0, 0.0], [Float64::NAN], [-1, 2], [0, 0]].each do |values|
      expect_raises(ArgumentError) { params.dashes = values }
      params.dashes.should eq([2.0, 4.0])
    end
    native = params.to_unsafe.value
    {native.dashes[0], native.dashes[1]}.should eq({2.0, 4.0})
  end

  it "revalidates mutations of the supplied array and getter result before native use" do
    values = [2.0, 4.0]
    params = UIng::Area::Draw::StrokeParams.new(dashes: values)
    params.to_unsafe

    values[0] = -1.0
    expect_raises(ArgumentError, /nonnegative/) { params.to_unsafe }

    values[0] = 0.0
    params.dashes[1] = 0.0
    expect_raises(ArgumentError, /positive length/) { params.to_unsafe }

    params.dashes[1] = Float64::NAN
    expect_raises(ArgumentError, /finite/) { params.to_unsafe }

    params.dashes[1] = 3.0
    params.to_unsafe.value.dashes[1].should eq(3.0)
  end
end
