require "./spec_helper"

describe UIng::Image do
  image = UIng::Image.new(Pointer(UIng::LibUI::Image).new(0x200_u64))

  it "rejects invalid dimensions for byte buffers" do
    pixels = Bytes.new(16)

    expect_raises(ArgumentError, /width must be positive/) { image.append(pixels, 0, 1, 4) }
    expect_raises(ArgumentError, /height must be positive/) { image.append(pixels, 1, 0, 4) }
    expect_raises(ArgumentError, /stride is too small/) { image.append(pixels, 2, 1, 7) }
  end

  it "rejects byte buffers shorter than the declared image" do
    pixels = Bytes.new(15)

    expect_raises(ArgumentError, /expected at least 16 bytes, got 15/) do
      image.append(pixels, 2, 2, 8)
    end
  end
end
