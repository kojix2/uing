require "../spec_helper"
require "../support/native_wrappers"

private class BlockConstructedImage < UIng::Image
  block_constructor
  getter native_free_calls = 0

  def initialize(width : Number, height : Number)
    super(Pointer(UIng::LibUI::Image).null)
  end

  protected def free_native : Nil
    @native_free_calls += 1
  end
end

describe UIng::Image do
  it "rejects invalid logical dimensions before creating a native image" do
    invalid_dimensions = [0.0, -1.0, Float64::NAN, Float64::INFINITY, Int32::MAX.to_f64 + 1]

    invalid_dimensions.each do |dimension|
      expect_raises(ArgumentError, /must be finite, positive/) { UIng::Image.new(dimension, 1) }
      expect_raises(ArgumentError, /must be finite, positive/) { UIng::Image.new(1, dimension) }
    end
  end

  it "rejects invalid dimensions for byte buffers" do
    image = UIng::Image.from_native_for_spec(Pointer(UIng::LibUI::Image).new(0x200_u64))
    pixels = Bytes.new(16)

    expect_raises(ArgumentError, /width must be positive/) { image.append(pixels, 0, 1, 4) }
    expect_raises(ArgumentError, /height must be positive/) { image.append(pixels, 1, 0, 4) }
    expect_raises(ArgumentError, /stride is too small/) { image.append(pixels, 2, 1, 7) }
    expect_raises(ArgumentError, /pixel width is too large/) do
      image.append(pixels.to_unsafe, Int32::MAX // 4 + 1, 1, Int32::MAX)
    end
    expect_raises(ArgumentError, /too large to retain for copying/) do
      image.append(pixels.to_unsafe, 1, Int32::MAX, Int32::MAX)
    end
  end

  it "rejects byte buffers shorter than the declared image" do
    image = UIng::Image.from_native_for_spec(Pointer(UIng::LibUI::Image).new(0x200_u64))
    pixels = Bytes.new(15)

    expect_raises(ArgumentError, /expected at least 16 bytes, got 15/) do
      image.append(pixels, 2, 2, 8)
    end
  end

  it "returns a live Image and supports implicit and explicit receivers" do
    yielded = nil
    image = BlockConstructedImage.new(1, 1) do |value|
      yielded = value
      to_unsafe.should eq(value.to_unsafe)
      :ignored
    end

    image.should be(yielded)
    image.native_free_calls.should eq(0)
    image.free
    image.native_free_calls.should eq(1)
  end

  it "frees a failed Image construction once and preserves the original error" do
    [false, true].each do |free_early|
      constructed = nil
      original = Exception.new("image construction failed")
      error = expect_raises(Exception, original.message) do
        BlockConstructedImage.new(width: 1, height: 1) do |image|
          constructed = image
          image.free if free_early
          raise original
        end
      end

      image = constructed.should_not be_nil
      error.should be(original)
      expect_raises(Exception, /already been released/) { image.to_unsafe }
      image.free
      image.native_free_calls.should eq(1)
    end
  end
end
