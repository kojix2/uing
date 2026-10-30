require "./spec_helper"

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

private class BlockConstructedImageBuffer < UIng::ImageBuffer
  block_constructor
  getter native_free_calls = 0

  def initialize(@width : Int32, @height : Int32, *, @format : Format = Format::RGBA8Straight)
    @ref_ptr = Pointer(UIng::LibUI::ImageBuffer).null
  end

  protected def free_native : Nil
    @native_free_calls += 1
  end
end

describe "image block construction" do
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

  it "configures an ImageBuffer with keyword arguments without freeing it" do
    yielded = nil
    buffer = BlockConstructedImageBuffer.new(width: 2, height: 1,
      format: UIng::ImageBuffer::Format::RGBA8Premultiplied) do |value|
      yielded = value
      size.should eq({2, 1})
      format.should eq(UIng::ImageBuffer::Format::RGBA8Premultiplied)
      :ignored
    end

    buffer.should be(yielded)
    buffer.released?.should be_false
    buffer.free
    buffer.native_free_calls.should eq(1)
  end

  it "frees a failed ImageBuffer construction once and preserves the original error" do
    [false, true].each do |free_early|
      constructed = nil
      original = Exception.new("buffer construction failed")
      error = expect_raises(Exception, original.message) do
        BlockConstructedImageBuffer.new(1, 1) do |buffer|
          constructed = buffer
          buffer.free if free_early
          raise original
        end
      end

      buffer = constructed.should_not be_nil
      error.should be(original)
      buffer.released?.should be_true
      buffer.free
      buffer.native_free_calls.should eq(1)
    end
  end

  it "keeps ImageBuffer.open returning its block result and freeing the buffer" do
    yielded = nil
    result = BlockConstructedImageBuffer.open(1, 1) do |buffer|
      yielded = buffer
      buffer.size.should eq({1, 1})
      :result
    end

    result.should eq(:result)
    yielded.should_not(be_nil).released?.should be_true
    yielded.should_not(be_nil).native_free_calls.should eq(1)
  end
end
