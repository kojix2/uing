require "../spec_helper"
require "../../src/uing/crimage"

# Capture the byte upload boundary without allocating a native image buffer.
class CrImageBufferForSpec < UIng::ImageBuffer
  getter uploaded : Bytes?
  getter uploaded_pointer : Pointer(UInt8)?
  getter uploaded_stride = 0_i64
  getter uploaded_rect : {Int32, Int32, Int32, Int32}?

  def initialize(@width : Int32, @height : Int32, @format : Format = Format::RGBA8Straight)
    @ref_ptr = Pointer(UIng::LibUI::ImageBuffer).null
  end

  def update(pixels : Bytes, *, byte_stride : Int = @width.to_i64 * 4) : Nil
    @uploaded = pixels.dup
    @uploaded_pointer = pixels.to_unsafe
    @uploaded_stride = byte_stride.to_i64
  end

  def release_for_spec : Nil
    @released = true
  end

  def update_rect(x : Int32, y : Int32, width : Int32, height : Int32,
                  pixels : Bytes, *, byte_stride : Int = width.to_i64 * 4) : Nil
    @uploaded_rect = {x, y, width, height}
    update(pixels, byte_stride: byte_stride)
  end
end

describe UIng::CrImageAdapter do
  describe "pixel conversion" do
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
  end

  describe "colors and gradients" do
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

    it "changes brush and stop colors without changing their geometry or position" do
      color = CrImage::Color::RGBA.new(128, 0, 0, 128)
      brush = UIng::Area::Draw::Brush.new(:linear_gradient, x0: 2, y0: 3, x1: 10, y1: 20)
      brush.color = color
      brush.type.should eq(UIng::Area::Draw::Brush::Type::LinearGradient)
      {brush.x0, brush.y0, brush.x1, brush.y1}.should eq({2.0, 3.0, 10.0, 20.0})
      {brush.r, brush.g, brush.b}.should eq({1.0, 0.0, 0.0})
      brush.a.should be_close(128.0 / 255, 1.0 / 255)

      stop = UIng::Area::Draw::Brush::GradientStop.new(0.4, 0, 0, 0, 1)
      stop.color = color
      stop.pos.should eq(0.4)
      {stop.r, stop.g, stop.b}.should eq({1.0, 0.0, 0.0})
      stop.a.should be_close(128.0 / 255, 1.0 / 255)
    end

    it "copies linear gradient geometry and translucent stops into an independent brush" do
      first = CrImage::Draw::ColorStop.new(0.0, CrImage::Color::RGBA.new(128, 0, 0, 128))
      last = CrImage::Draw::ColorStop.new(1.0, CrImage::Color.parse("#0000FF"))
      gradient = CrImage::Draw::LinearGradient.new(CrImage.point(-4, 6), CrImage.point(20, 30), [first, last])
      brush = UIng::Area::Draw::Brush.from_crimage(gradient)

      brush.type.should eq(UIng::Area::Draw::Brush::Type::LinearGradient)
      {brush.x0, brush.y0, brush.x1, brush.y1}.should eq({-4.0, 6.0, 20.0, 30.0})
      brush.stops.map(&.pos).should eq([0.0, 1.0])
      brush.stops.first.r.should eq(1.0)
      brush.stops.first.a.should be_close(128.0 / 255, 1.0 / 255)
      brush.stops.last.b.should eq(1.0)
      gradient.stops.clear
      GC.collect
      brush.num_stops.should eq(2)
      brush.to_unsafe.value.stops[1].b.should eq(1.0)
    end

    it "converts a radial gradient into concentric native circles" do
      stop = CrImage::Draw::ColorStop.new(0.25, CrImage::Color.parse("#FFFFFF"))
      gradient = CrImage::Draw::RadialGradient.new(CrImage.point(15, 25), 40, [stop])
      brush = UIng::Area::Draw::Brush.from_crimage(gradient)

      brush.type.should eq(UIng::Area::Draw::Brush::Type::RadialGradient)
      {brush.x0, brush.y0, brush.x1, brush.y1}.should eq({15.0, 25.0, 15.0, 25.0})
      brush.outer_radius.should eq(40.0)
      brush.stops.first.pos.should eq(0.25)
      gradient.radius = 0
      expect_raises(ArgumentError, /radius must be finite and positive/) do
        UIng::Area::Draw::Brush.from_crimage(gradient)
      end
    end

    it "validates mutable CrImage gradient stops before converting them" do
      stop = CrImage::Draw::ColorStop.new(0.0, CrImage::Color.parse("#FFFFFF"))
      gradient = CrImage::Draw::LinearGradient.new(CrImage.point(0, 0), CrImage.point(10, 0), [stop])
      gradient.stops.clear
      expect_raises(CrImage::InvalidGradientError, /at least one color stop/) do
        UIng::Area::Draw::Brush.from_crimage(gradient)
      end
    end
  end
end

describe "UIng::ImageBuffer CrImage integration" do
  describe "image storage and alpha conversion" do
    it "reuses matching premultiplied storage with its original row stride" do
      pixels = Bytes[128, 0, 0, 128, 0, 0, 0, 0, 0, 64, 0, 128, 0, 0, 0, 0]
      source = CrImage::RGBA.new(pixels, 8, CrImage.rect(5, 7, 6, 9))
      buffer = CrImageBufferForSpec.new(1, 2, :rgba8_premultiplied)

      buffer.update(source).should be_nil
      buffer.uploaded_pointer.should eq(pixels.to_unsafe)
      buffer.uploaded_stride.should eq(8)
      buffer.uploaded.should eq(pixels)
    end

    it "reuses straight NRGBA storage for a straight buffer" do
      pixels = Bytes[255, 32, 0, 128]
      source = CrImage::NRGBA.new(pixels, 4, CrImage.rect(0, 0, 1, 1))
      buffer = CrImageBufferForSpec.new(1, 1)

      buffer.update(source)
      buffer.uploaded_pointer.should eq(pixels.to_unsafe)
      buffer.uploaded.should eq(pixels)
    end

    it "unpremultiplies RGBA for the default straight format without changing the source" do
      pixels = Bytes[128, 0, 0, 128, 0, 0, 0, 0]
      source = CrImage::RGBA.from_buffer(pixels, 2, 1)
      buffer = CrImageBufferForSpec.new(2, 1)

      buffer.update(source)
      buffer.uploaded.should eq(Bytes[255, 0, 0, 128, 0, 0, 0, 0])
      source.pix.should eq(pixels)
      pixels.should eq(Bytes[128, 0, 0, 128, 0, 0, 0, 0])
    end

    it "premultiplies NRGBA exactly once for a premultiplied buffer" do
      source = CrImage::NRGBA.new(CrImage.rect(0, 0, 1, 1))
      source.set_nrgba(0, 0, CrImage::Color::NRGBA.new(255, 0, 0, 128))
      buffer = CrImageBufferForSpec.new(1, 1, :rgba8_premultiplied)

      buffer.update(source)
      buffer.uploaded.should eq(Bytes[128, 0, 0, 128])
      source.pix.should eq(Bytes[255, 0, 0, 128])
    end

    it "converts other image types at a nonzero origin" do
      source = CrImage::Gray.new(CrImage.rect(5, 7, 6, 8))
      source.set_gray(5, 7, CrImage::Color::Gray.new(80))
      buffer = CrImageBufferForSpec.new(1, 1)

      buffer.update(source)
      buffer.uploaded.should eq(Bytes[80, 80, 80, 255])
      buffer.uploaded_stride.should eq(4)
    end
  end

  describe "visible image bounds and partial uploads" do
    it "uploads only visible pixels of a subimage with missing final-row padding" do
      source = CrImage::RGBA.from_buffer(
        Bytes[1, 2, 3, 255, 4, 5, 6, 255, 7, 8, 9, 255, 10, 11, 12, 255], 2, 2)
      subimage = source.sub_image(CrImage.rect(1, 1, 2, 2))
      buffer = CrImageBufferForSpec.new(1, 1, :rgba8_premultiplied)

      buffer.update(subimage)
      buffer.uploaded.should eq(Bytes[10, 11, 12, 255])
      buffer.uploaded_stride.should eq(4)
    end

    it "infers patch dimensions from visible bounds and converts alpha for partial uploads" do
      source = CrImage::RGBA.new(Bytes[128, 0, 0, 128, 0, 0, 0, 0], 4, CrImage.rect(5, 7, 6, 9))
      buffer = CrImageBufferForSpec.new(4, 4)

      buffer.update_rect(2, 1, source)
      buffer.uploaded_rect.should eq({2, 1, 1, 2})
      buffer.uploaded_stride.should eq(4)
      buffer.uploaded.should eq(Bytes[255, 0, 0, 128, 0, 0, 0, 0])
    end

    it "rejects mismatched dimensions and malformed storage before uploading" do
      buffer = CrImageBufferForSpec.new(1, 2)
      expect_raises(ArgumentError, /dimensions must match/) { buffer.update(CrImage.rgba(2, 1)) }
      malformed = CrImage::NRGBA.new(Bytes.new(4), 4, CrImage.rect(0, 0, 1, 2))
      expect_raises(ArgumentError, /does not cover its bounds/) { buffer.update(malformed) }
      buffer.uploaded.should be_nil
    end
  end

  describe "buffer lifetime" do
    it "rejects CrImage updates after the buffer has been released" do
      buffer = CrImageBufferForSpec.new(1, 1)
      buffer.release_for_spec
      expect_raises(RuntimeError, /already been released/) { buffer.update(CrImage.rgba(1, 1)) }
      expect_raises(RuntimeError, /already been released/) { buffer.update_rect(0, 0, CrImage.rgba(1, 1)) }
      buffer.uploaded.should be_nil
    end
  end
end
