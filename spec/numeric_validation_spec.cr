require "big"
require "./spec_helper"

describe "numeric input validation" do
  it "converts accepted Number inputs to Float64" do
    stop = UIng::Area::Draw::Brush::GradientStop.new(pos: 0, r: 1, g: 0, b: 1, a: 1)
    params = UIng::Area::Draw::StrokeParams.new(thickness: 2, dash_phase: -1)

    {stop.pos, stop.r, params.thickness, params.dash_phase}.should eq({0.0, 1.0, 2.0, -1.0})
  end

  it "rejects non-finite values with ArgumentError" do
    [Float64::NAN, Float64::INFINITY, -Float64::INFINITY].each do |value|
      expect_raises(ArgumentError, /must be finite/) do
        UIng::Area::Draw::Matrix.new.translate(value, 0)
      end
    end

    matrix = UIng::Area::Draw::Matrix.new
    expect_raises(ArgumentError, /matrix translation x must be finite/) do
      matrix.translate(Float64::NAN, 0)
    end

    path = UIng::Area::Draw::Path.new(Pointer(UIng::LibUI::DrawPath).null)
    expect_raises(ArgumentError, /path y must be finite/) do
      path.new_figure(0, Float64::INFINITY)
    end
    expect_raises(ArgumentError, /path arc radius must be finite/) do
      path.arc_to(0, 0, Float64::NAN, 0, Math::PI, false)
    end

    expect_raises(ArgumentError, /must be representable as Float64/) do
      matrix.translate(BigDecimal.new("1e10000"), 0)
    end
  end

  it "rejects values outside normalized ranges" do
    expect_raises(ArgumentError, /gradient stop position must be finite and between 0 and 1/) do
      UIng::Area::Draw::Brush::GradientStop.new(pos: 1.01)
    end
    expect_raises(ArgumentError, /brush red must be finite and between 0 and 1/) do
      UIng::Area::Draw::Brush.new(UIng::Area::Draw::Brush::Type::Solid, r: -0.01)
    end
    expect_raises(ArgumentError, /text color alpha must be finite and between 0 and 1/) do
      UIng::Area::Attribute.new_color(0, 0, 0, Float64::NAN)
    end
    expect_raises(ArgumentError, /table color blue must be finite and between 0 and 1/) do
      UIng::Table::Value.new_color(0, 0, 2, 1)
    end
  end

  it "rejects zero or negative positive-only values" do
    expect_raises(ArgumentError, /font descriptor size must be finite and positive/) do
      UIng::FontDescriptor.new(
        family: "Inter",
        size: 0,
        weight: UIng::TextWeight::Normal,
        italic: UIng::TextItalic::Normal,
        stretch: UIng::TextStretch::Normal
      )
    end
    expect_raises(ArgumentError, /stroke thickness must be finite and positive/) do
      UIng::Area::Draw::StrokeParams.new(thickness: 0)
    end
  end
end
