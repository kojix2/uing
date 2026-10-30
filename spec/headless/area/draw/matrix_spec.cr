require "../../../spec_helper"
require "big"

describe UIng::Area::Draw::Matrix do
  it "rejects non-finite and unrepresentable values with ArgumentError" do
    [Float64::NAN, Float64::INFINITY, -Float64::INFINITY].each do |value|
      expect_raises(ArgumentError, /must be finite/) do
        UIng::Area::Draw::Matrix.new.translate(value, 0)
      end
    end

    matrix = UIng::Area::Draw::Matrix.new
    expect_raises(ArgumentError, /matrix translation x must be finite/) do
      matrix.translate(Float64::NAN, 0)
    end

    expect_raises(ArgumentError, /must be representable as Float64/) do
      matrix.translate(BigDecimal.new("1e10000"), 0)
    end
  end

  it "accepts integer coordinates for floating-point transformations" do
    matrix = UIng::Area::Draw::Matrix.new
    matrix.set_identity
    matrix.translate(2, 3)

    matrix.transform_point(1, 1).should eq({3.0, 4.0})
  end
end
