require "../spec_helper"
require "../support/native_wrappers"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  require "../../src/uing/crimage"

  describe UIng::ImageBuffer do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "returns a live buffer after configuration and frees it when configuration raises" do
      normal = UIng::ImageBuffer.new(1, 1) do
        update(Bytes[255, 0, 0, 255])
      end
      normal.released?.should be_false
      normal.free

      [false, true].each do |free_early|
        escaped = nil
        expect_raises(Exception, "buffer configuration failed") do
          UIng::ImageBuffer.new(1, 1) do |buffer|
            escaped = buffer
            update(Bytes[255, 0, 0, 255])
            buffer.free if free_early
            raise "buffer configuration failed"
          end
        end

        buffer = escaped.should_not be_nil
        buffer.released?.should be_true
        buffer.free
      end
    ensure
      normal.try &.free
    end

    it "owns a fixed-size buffer in each input format" do
      UIng::ImageBuffer::Format.each do |format|
        UIng::ImageBuffer.open(3, 2, format: format) do |buffer|
          buffer.size.should eq({3, 2})
          {buffer.width, buffer.height, buffer.format}.should eq({3, 2, format})
          buffer.released?.should be_false
          UIng::LibUI.image_buffer_get_size(buffer, out width, out height)
          {width, height}.should eq(buffer.size)
          buffer.update(Bytes.new(24)).should be_nil
          buffer.update(Bytes.new(28), byte_stride: 16).should be_nil
          buffer.update_rect(2, 1, 1, 1, Bytes[40, 30, 20, 128]).should be_nil
          buffer.update_rect(1, 0, 2, 2, Bytes.new(20), byte_stride: 12).should be_nil
        end
      end
      UIng::ImageBuffer.open(1, 1, format: :rgba8_straight) do |buffer|
        buffer.format.should eq(UIng::ImageBuffer::Format::RGBA8Straight)
      end
    end

    it "rejects invalid dimensions, formats, and overflowing storage sizes" do
      expect_raises(ArgumentError, /width must be positive/) { UIng::ImageBuffer.new(0, 1) }
      expect_raises(ArgumentError, /height must be positive/) { UIng::ImageBuffer.new(1, -1) }
      expect_raises(ArgumentError, /unsupported.*format/) do
        UIng::ImageBuffer.new(1, 1, format: UIng::ImageBuffer::Format.new(2))
      end
      expect_raises(ArgumentError, /too large to address/) do
        UIng::ImageBuffer.new(Int32::MAX, Int32::MAX)
      end
      {% if flag?(:win32) && flag?(:bits64) %}
        # Windows rejects a row pitch above UINT32_MAX before allocating it.
        expect_raises(UIng::ImageBuffer::Error, /could not create/) do
          UIng::ImageBuffer.new(Int32::MAX, 1)
        end
      {% end %}
    end

    it "updates from CrImage images in either input format" do
      premultiplied = CrImage::RGBA.from_buffer(Bytes[128, 0, 0, 128], 1, 1)
      straight = CrImage::NRGBA.new(CrImage.rect(0, 0, 1, 1))
      straight.set_nrgba(0, 0, CrImage::Color::NRGBA.new(255, 0, 0, 128))
      UIng::ImageBuffer::Format.each do |format|
        UIng::ImageBuffer.open(1, 1, format: format) do |buffer|
          buffer.update(premultiplied).should be_nil
          buffer.update(straight).should be_nil
        end
      end
    end

    it "creates a filled buffer with dimensions and format inferred from the source" do
      rgba = CrImage::RGBA.from_buffer(Bytes[128, 0, 0, 128], 1, 1)
      nrgba = CrImage::NRGBA.new(CrImage.rect(5, 7, 6, 8))
      nrgba.set_nrgba(5, 7, CrImage::Color::NRGBA.new(255, 0, 0, 128))
      nrgba64 = CrImage::NRGBA64.new(CrImage.rect(0, 0, 1, 1))
      nrgba64.set_nrgba64(0, 0, CrImage::Color::NRGBA64.new(65535, 0, 0, 32768))
      [
        {rgba, UIng::ImageBuffer::Format::RGBA8Premultiplied},
        {nrgba, UIng::ImageBuffer::Format::RGBA8Straight},
        {nrgba64, UIng::ImageBuffer::Format::RGBA8Straight},
      ].each do |source, expected_format|
        buffer = UIng::ImageBuffer.new(source) do
          size.should eq({1, 1})
          format.should eq(expected_format)
          update(source)
        end
        begin
          buffer.size.should eq({1, 1})
          buffer.format.should eq(expected_format)
          buffer.update(source).should be_nil
        ensure
          buffer.free
        end
      end
      UIng::ImageBuffer.open(rgba, format: :rgba8_straight) do |buffer|
        buffer.format.should eq(UIng::ImageBuffer::Format::RGBA8Straight)
      end
    end

    it "frees a buffer created from CrImage when its configuration block raises" do
      source = CrImage.rgba(1, 1)
      escaped = nil
      expect_raises(Exception, "CrImage configuration failed") do
        UIng::ImageBuffer.new(source) do |buffer|
          escaped = buffer
          format.should eq(UIng::ImageBuffer::Format::RGBA8Premultiplied)
          raise "CrImage configuration failed"
        end
      end

      buffer = escaped.should_not be_nil
      buffer.released?.should be_true
      buffer.free
    end

    it "frees image-based open buffers on normal and exceptional block exit" do
      source = CrImage.rgba(1, 1)
      normal = nil
      result = UIng::ImageBuffer.open(source) { |buffer| normal = buffer; 42 }
      result.should eq(42)
      normal.not_nil!.released?.should be_true
      exceptional = nil
      expect_raises(Exception, "CrImage block failure") do
        UIng::ImageBuffer.open(source) do |buffer|
          exceptional = buffer
          raise "CrImage block failure"
        end
      end
      exceptional.not_nil!.released?.should be_true
      malformed = CrImage::RGBA.new(Bytes.new(4), 4, CrImage.rect(0, 0, 1, 2))
      expect_raises(ArgumentError, /does not cover its bounds/) { UIng::ImageBuffer.new(malformed) }
    end

    it "updates a CrImage patch and rejects destinations outside the buffer" do
      patch = CrImage::NRGBA.new(CrImage.rect(5, 7, 6, 8))
      patch.set_nrgba(5, 7, CrImage::Color::NRGBA.new(255, 0, 0, 128))
      UIng::ImageBuffer.open(CrImage.rgba(3, 2)) do |buffer|
        buffer.update_rect(2, 1, patch).should be_nil
        expect_raises(ArgumentError, /update rectangle/) { buffer.update_rect(3, 1, patch) }
        expect_raises(ArgumentError, /update rectangle/) { buffer.update_rect(-1, 0, patch) }
        buffer.free
        expect_raises(RuntimeError, /already been released/) { buffer.update_rect(0, 0, patch) }
      end
    end

    it "rejects short input, invalid stride, and span overflow before native updates" do
      UIng::ImageBuffer.open(3, 2) do |buffer|
        expect_raises(ArgumentError, /expected at least 28 bytes, got 27/) do
          buffer.update(Bytes.new(27), byte_stride: 16)
        end
        [-1, 0, 11].each do |stride|
          expect_raises(ArgumentError, /byte stride/) { buffer.update(Bytes.new(24), byte_stride: stride) }
        end
        expect_raises(ArgumentError, /span is too large/) do
          buffer.update(Bytes.new(24), byte_stride: UInt64::MAX)
        end
        expect_raises(ArgumentError, /byte stride/) do
          buffer.update(Bytes.new(24), byte_stride: UInt128::MAX)
        end
        expect_raises(ArgumentError, /expected at least 20 bytes, got 19/) do
          buffer.update_rect(1, 0, 2, 2, Bytes.new(19), byte_stride: 12)
        end
        # Failed validations leave the wrapper usable.
        buffer.update(Bytes.new(24))
      end
      UIng::ImageBuffer.open(1, 1) do |buffer|
        # The final row never reads its padding, even with the maximum stride.
        buffer.update(Bytes[0, 0, 0, 0], byte_stride: LibC::SizeT::MAX)
      end
    end

    it "rejects rectangles outside the buffer without overflowing their edges" do
      UIng::ImageBuffer.open(3, 2) do |buffer|
        [{-1, 0, 1, 1}, {0, -1, 1, 1}, {0, 0, 0, 1}, {0, 0, 1, -1},
         {3, 0, 1, 1}, {0, 2, 1, 1}, {2, 1, 2, 1},
         {Int32::MAX, 0, Int32::MAX, 1}].each do |rect|
          expect_raises(ArgumentError, /update rectangle/) do
            buffer.update_rect(*rect, Bytes.new(16))
          end
        end
      end
    end

    it "frees idempotently and rejects use after release" do
      buffer = UIng::ImageBuffer.new(1, 1)
      buffer.free
      buffer.free
      buffer.released?.should be_true
      expect_raises(RuntimeError, /already been released/) { buffer.size }
      expect_raises(RuntimeError, /already been released/) { buffer.format }
      expect_raises(RuntimeError, /already been released/) { buffer.to_unsafe }
      expect_raises(RuntimeError, /already been released/) { buffer.update(Bytes.new(4)) }
      expect_raises(RuntimeError, /already been released/) { buffer.update_rect(0, 0, 1, 1, Bytes.new(4)) }
      context = UIng::Area::Draw::Context.from_native_for_spec(Pointer(UIng::LibUI::DrawContext).null)
      expect_raises(RuntimeError, /already been released/) { context.draw_image(buffer, 0, 0, 1, 1) }
    end

    it "returns the open block value and frees on normal and exceptional exit" do
      normal = nil
      result = UIng::ImageBuffer.open(1, 1) do |buffer|
        normal = buffer
        buffer.free # open also permits explicit early release.
        42
      end
      result.should eq(42)
      normal.not_nil!.released?.should be_true
      exceptional = nil
      expect_raises(Exception, "buffer block failure") do
        UIng::ImageBuffer.open(1, 1) do |buffer|
          exceptional = buffer
          raise "buffer block failure"
        end
      end
      exceptional.not_nil!.released?.should be_true
    end

    it "validates the source rectangle through both drawing layers" do
      UIng::ImageBuffer.open(3, 2) do |buffer|
        context = UIng::Area::Draw::Context.from_native_for_spec(Pointer(UIng::LibUI::DrawContext).null)
        params = UIng::Area::Draw::ImageBufferParams.new(
          source_x: 2, source_y: 1, source_width: 2, source_height: 1,
          x: 0, y: 0, width: 1, height: 1)
        expect_raises(ArgumentError, /source rectangle must fit/) do
          context.draw_image_buffer_with_params(buffer, params)
        end
        expect_raises(ArgumentError, /source rectangle must fit/) do
          context.draw_image(buffer, 0, 0, 1, 1, source: {x: 2, y: 1, width: 2, height: 1})
        end
        expect_raises(ArgumentError, /draw width must be finite and positive/) do
          context.draw_image_buffer(buffer, 0, 0, 0, 1)
        end
        expect_raises(ArgumentError, /draw x must be finite/) do
          context.draw_image(buffer, Float64::NAN, 0, 1, 1)
        end
        expect_raises(ArgumentError, /destination edges/) do
          context.draw_image(buffer, Float64::MAX, 0, 1, 1)
        end
        params.source_x = Int32::MAX
        params.source_width = Int32::MAX
        expect_raises(ArgumentError, /source rectangle must fit/) do
          context.draw_image_buffer_with_params(buffer, params)
        end
      end
    end

    it "draws through both C-shaped methods and both convenience overload paths" do
      UIng::ImageBuffer.open(3, 2) do |buffer|
        buffer.update(Bytes.new(24))
        drawn = false
        errors = [] of Exception
        escaped_context = nil
        window = UIng::Window.new("ImageBuffer wrappers", 200, 100)
        area = UIng::Area.new
        window.child = area
        crop = UIng::Area::Draw::ImageBufferParams.new(
          source_x: 2, source_y: 1, source_width: 1, source_height: 1,
          x: 20, y: 0, width: 16, height: 16, interpolation: :nearest)
        area.on_draw do |params|
          temporary = nil
          begin
            context = params.context
            escaped_context = context
            context.draw_image_buffer(buffer, 0, 0, 16, 16, :nearest)
            buffer.update_rect(2, 1, 1, 1, Bytes[255, 0, 0, 255])
            context.draw_image_buffer_with_params(buffer, crop)
            context.draw_image(buffer, 40, 0, 16, 16)
            context.draw_image(buffer, 60, 0, 16, 16,
              source: {x: 2, y: 1, width: 1, height: 1}, interpolation: :nearest)
            temporary = UIng::ImageBuffer.new(1, 1)
            temporary.update(Bytes[0, 0, 255, 255])
            context.draw_image(temporary, 0, 20, 16, 16)
            temporary.free
            drawn = true
          rescue error
            errors << error
          ensure
            temporary.try &.free
          end
        end
        begin
          UIng.main_steps
          window.show
          deadline = Time.instant + 5.seconds
          until drawn || !errors.empty? || Time.instant >= deadline
            UIng.main_step(false)
            sleep 1.millisecond
          end
          errors.should be_empty
          drawn.should be_true
          expect_raises(Exception, /context is no longer available/) do
            escaped_context.not_nil!.draw_image_buffer(buffer, 0, 0, 1, 1)
          end
          expect_raises(Exception, /context is no longer available/) do
            escaped_context.not_nil!.draw_image_buffer_with_params(buffer, crop)
          end
        ensure
          window.destroy
        end
      end
    end
  end
{% end %}
