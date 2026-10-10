require "./spec_helper"
require "../src/uing/crimage"

describe UIng::CrImageAdapter do
  it "passes a full premultiplied RGBA buffer through without copying" do
    pixels = Bytes[64, 0, 0, 128]
    source = CrImage::RGBA.from_buffer(pixels, 1, 1)

    UIng::CrImageAdapter.with_pixels(source) do |result, width, height, stride|
      result.to_unsafe.should eq(pixels.to_unsafe)
      {width, height, stride}.should eq({1, 1, 4})
      result.should eq(pixels)
    end
  end

  it "converts non-premultiplied pixels at a nonzero origin" do
    source = CrImage::NRGBA.new(CrImage.rect(5, 7, 6, 8))
    color = CrImage::Color::NRGBA.new(255, 0, 0, 128)
    source.set_nrgba(5, 7, color)

    UIng::CrImageAdapter.with_pixels(source) do |pixels, width, height, stride|
      {width, height, stride}.should eq({1, 1, 4})
      converted = color.to_rgba8
      pixels.should eq(Bytes[converted.r, converted.g, converted.b, converted.a])
    end
  end

  it "copies only visible pixels from a subimage with a shared stride" do
    source = CrImage::RGBA.from_buffer(
      Bytes[1, 2, 3, 255, 4, 5, 6, 255, 7, 8, 9, 255, 10, 11, 12, 255],
      2, 2
    )
    subimage = source.sub_image(CrImage.rect(1, 1, 2, 2))

    UIng::CrImageAdapter.with_pixels(subimage) do |pixels, width, height, stride|
      {width, height, stride}.should eq({1, 1, 4})
      pixels.should eq(Bytes[10, 11, 12, 255])
    end
  end

  it "rejects empty images before creating a native image" do
    expect_raises(ArgumentError, /width and height must be positive/) do
      UIng::CrImageAdapter.dimensions(CrImage::RGBA.new)
    end
  end

  it "rejects malformed RGBA buffers before reading their pixels" do
    source = CrImage::RGBA.new(Bytes.new(4), 4, CrImage.rect(0, 0, 2, 1))
    expect_raises(ArgumentError, /does not cover its bounds/) do
      UIng::CrImageAdapter.with_pixels(source) { |_pixels, _width, _height, _stride| }
    end
  end

  it "converts premultiplied image colors to straight UI colors" do
    straight = CrImage::Color::NRGBA.new(255, 0, 0, 128)
    red, green, blue, alpha = straight.to_uing_rgba
    red.should be_close(1.0, 1.0 / 255)
    green.should eq(0.0)
    blue.should eq(0.0)
    alpha.should be_close(128.0 / 255, 1.0 / 255)

    premultiplied = CrImage::Color::RGBA.new(64, 0, 0, 128)
    red, _, _, alpha = premultiplied.to_uing_rgba
    red.should be_close(0.5, 2.0 / 255)
    alpha.should be_close(128.0 / 255, 1.0 / 255)

    high_precision = CrImage::Color::NRGBA64.new(65535, 32768, 0, 65535)
    _, green, _, _ = high_precision.to_uing_rgba
    green.should be_close(32768.0 / 65535, 1.0 / 65535)
  end

  it "uses straight UI colors in brushes and gradient stops" do
    color = CrImage::Color::NRGBA.new(255, 0, 0, 128)
    brush = UIng::Area::Draw::Brush.solid(color)
    brush.r.should be_close(1.0, 1.0 / 255)
    brush.a.should be_close(128.0 / 255, 1.0 / 255)

    stop = UIng::Area::Draw::Brush::GradientStop.new(0.5, color)
    stop.pos.should eq(0.5)
    stop.r.should be_close(1.0, 1.0 / 255)
    stop.a.should be_close(128.0 / 255, 1.0 / 255)
  end
end
