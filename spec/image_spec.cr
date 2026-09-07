require "./spec_helper"

describe UIng::Image do
  image = UIng::Image.new(Pointer(UIng::LibUI::Image).new(0x200_u64))

  it "rejects invalid logical dimensions before creating a native image" do
    invalid_dimensions = [0.0, -1.0, Float64::NAN, Float64::INFINITY, Int32::MAX.to_f64 + 1]

    invalid_dimensions.each do |dimension|
      expect_raises(ArgumentError, /must be finite, positive/) { UIng::Image.new(dimension, 1) }
      expect_raises(ArgumentError, /must be finite, positive/) { UIng::Image.new(1, dimension) }
    end
  end

  it "rejects invalid dimensions for byte buffers" do
    pixels = Bytes.new(16)

    expect_raises(ArgumentError, /width must be positive/) { image.append(pixels, 0, 1, 4) }
    expect_raises(ArgumentError, /height must be positive/) { image.append(pixels, 1, 0, 4) }
    expect_raises(ArgumentError, /stride is too small/) { image.append(pixels, 2, 1, 7) }
    expect_raises(ArgumentError, /pixel width is too large/) do
      image.append(pixels.to_unsafe, Int32::MAX // 4 + 1, 1, Int32::MAX)
    end
  end

  it "rejects byte buffers shorter than the declared image" do
    pixels = Bytes.new(15)

    expect_raises(ArgumentError, /expected at least 16 bytes, got 15/) do
      image.append(pixels, 2, 2, 8)
    end
  end
end
