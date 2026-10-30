require "../../../spec_helper"

private def image_buffer_params(interpolation : UIng::ImageBuffer::Interpolation = UIng::ImageBuffer::Interpolation::Smooth)
  UIng::Area::Draw::ImageBufferParams.new(
    source_x: 1, source_y: 2, source_width: 3, source_height: 4,
    x: 5, y: 6, width: 7, height: 8, interpolation: interpolation)
end

describe UIng::Area::Draw::ImageBufferParams do
  it "owns a native parameter structure and fills the size automatically" do
    params = image_buffer_params(interpolation: :nearest)
    native = params.to_unsafe.value
    native.size.should eq(sizeof(UIng::LibUI::DrawImageBufferParams))
    {native.source_x, native.source_y, native.source_width, native.source_height}.should eq({1, 2, 3, 4})
    {native.x, native.y, native.width, native.height}.should eq({5.0, 6.0, 7.0, 8.0})
    native.interpolation.should eq(UIng::ImageBuffer::Interpolation::Nearest)

    params.source_x = 0
    params.source_y = 1
    params.source_width = 2
    params.source_height = 3
    params.x = -2
    params.y = 0.5
    params.width = 11
    params.height = 12
    params.interpolation = :smooth
    native = params.to_unsafe.value
    {native.source_x, native.source_y, native.source_width, native.source_height}.should eq({0, 1, 2, 3})
    {native.x, native.y, native.width, native.height}.should eq({-2.0, 0.5, 11.0, 12.0})
    native.interpolation.should eq(UIng::ImageBuffer::Interpolation::Smooth)
  end

  it "supports the established parameter block constructor" do
    params = UIng::Area::Draw::ImageBufferParams.new(
      source_x: 0, source_y: 0, source_width: 1, source_height: 1,
      x: 0, y: 0, width: 1, height: 1) do |value|
      value.width = 20
    end
    params.width.should eq(20)
  end

  it "rejects invalid source coordinates and sizes without changing the fields" do
    params = image_buffer_params
    expect_raises(ArgumentError, /source_x must be nonnegative/) { params.source_x = -1 }
    expect_raises(ArgumentError, /source_y must be nonnegative/) { params.source_y = -1 }
    expect_raises(ArgumentError, /source_width must be positive/) { params.source_width = 0 }
    expect_raises(ArgumentError, /source_height must be positive/) { params.source_height = -1 }
    {params.source_x, params.source_y, params.source_width, params.source_height}.should eq({1, 2, 3, 4})
  end

  it "rejects nonfinite geometry, empty destinations, and unknown interpolation" do
    params = image_buffer_params
    [Float64::NAN, Float64::INFINITY, -Float64::INFINITY].each do |invalid|
      expect_raises(ArgumentError, /draw x must be finite/) { params.x = invalid }
      expect_raises(ArgumentError, /draw y must be finite/) { params.y = invalid }
      expect_raises(ArgumentError, /width must be finite and positive/) { params.width = invalid }
      expect_raises(ArgumentError, /height must be finite and positive/) { params.height = invalid }
    end
    expect_raises(ArgumentError, /width must be finite and positive/) { params.width = 0 }
    expect_raises(ArgumentError, /height must be finite and positive/) { params.height = -1 }
    expect_raises(ArgumentError, /unsupported.*interpolation/) do
      params.interpolation = UIng::ImageBuffer::Interpolation.new(2)
    end
  end

  it "checks destination edge overflow and precision loss again after mutation" do
    params = image_buffer_params
    params.x = Float64::MAX
    params.width = Float64::MAX
    expect_raises(ArgumentError, /destination edges/) { params.to_unsafe }
    params.width = 1
    expect_raises(ArgumentError, /destination edges/) { params.to_unsafe }
    params.x = 0
    params.y = Float64::MAX
    expect_raises(ArgumentError, /destination edges/) { params.to_unsafe }
    params.y = 0
    params.to_unsafe.value.width.should eq(1)
  end
end
