# Optional CrImage integration. Applications using this entry point must add
# crimage to their own shard.yml dependencies.
require "../uing"
require "crimage"

module UIng
  # :nodoc:
  module CrImageAdapter
    extend self

    def dimensions(source : CrImage::Image) : {Int32, Int32}
      bounds = source.bounds
      width = bounds.max.x.to_i64 - bounds.min.x
      height = bounds.max.y.to_i64 - bounds.min.y
      raise ArgumentError.new("image width and height must be positive") unless width > 0 && height > 0
      raise ArgumentError.new("image width is too large for RGBA pixels") if width > Int32::MAX // 4

      byte_count = width * height * 4
      raise ArgumentError.new("image pixel buffer is too large") if byte_count > Int32::MAX
      {width.to_i32, height.to_i32}
    end

    def with_pixels(source : CrImage::Image, *, premultiplied : Bool = true, &) : Nil
      width, height = dimensions(source)
      row_bytes = width * 4

      if source.is_a?(CrImage::RGBA) || source.is_a?(CrImage::NRGBA)
        stride = source.stride
        visible_bytes = (height.to_i64 - 1) * stride + row_bytes
        if stride < row_bytes || visible_bytes > source.pix.size
          raise ArgumentError.new("CrImage RGBA pixel buffer does not cover its bounds")
        end

        if source.is_a?(CrImage::RGBA) == premultiplied && source.pix.size.to_i64 >= stride.to_i64 * height
          yield source.pix, width, height, stride
          return
        end
      end

      pixels = Bytes.new(row_bytes * height)
      bounds = source.bounds
      height.times do |y|
        width.times do |x|
          color = source.at(bounds.min.x + x, bounds.min.y + y)
          color = premultiplied ? color.to_rgba8 : CrImage::Color.nrgba_model.convert(color).as(CrImage::Color::NRGBA)
          offset = y * row_bytes + x * 4
          pixels[offset] = color.r
          pixels[offset + 1] = color.g
          pixels[offset + 2] = color.b
          pixels[offset + 3] = color.a
        end
      end
      yield pixels, width, height, row_bytes
    end

    def rgba(color : CrImage::Color::Color) : {Float64, Float64, Float64, Float64}
      straight = CrImage::Color.nrgba64_model.convert(color).as(CrImage::Color::NRGBA64)
      {straight.r / 65535.0, straight.g / 65535.0,
       straight.b / 65535.0, straight.a / 65535.0}
    end

    def byte(value : Float64) : UInt8
      (value * 255.0).round.to_i.clamp(0, 255).to_u8
    end

    def image_buffer_format(source : CrImage::Image) : ImageBuffer::Format
      if source.is_a?(CrImage::NRGBA) || source.is_a?(CrImage::NRGBA64)
        ImageBuffer::Format::RGBA8Straight
      else
        ImageBuffer::Format::RGBA8Premultiplied
      end
    end

    def with_image(source : CrImage::Image, &)
      image = Image.from_crimage(source)
      begin
        yield image
      ensure
        image.free
      end
    end
  end

  class ImageBuffer
    # Creates and fills a buffer. NRGBA/NRGBA64 use straight alpha; other image
    # types use premultiplied alpha. An explicit format overrides that choice.
    def initialize(source : CrImage::Image, *, format : Format = CrImageAdapter.image_buffer_format(source))
      width, height = CrImageAdapter.dimensions(source)
      initialize(width, height, format: format)
      begin
        update(source)
      rescue error
        free
        raise error
      end
    end

    # Keeps the event loop inside the block and frees the buffer on every exit.
    def self.open(source : CrImage::Image, *, format : Format = CrImageAdapter.image_buffer_format(source), &)
      buffer = new(source, format: format)
      begin
        yield buffer
      ensure
        buffer.free
      end
    end

    # Copies a CrImage image with matching dimensions. Alpha representation and
    # stride are adapted to this buffer's format. Does not request a redraw.
    def update(source : CrImage::Image) : Nil
      buffer_size = size
      unless CrImageAdapter.dimensions(source) == buffer_size
        raise ArgumentError.new("CrImage dimensions must match the image buffer")
      end
      CrImageAdapter.with_pixels(source, premultiplied: @format == Format::RGBA8Premultiplied) do |pixels, _width, _height, stride|
        update(pixels, byte_stride: stride)
      end
    end

    # Copies the entire patch at destination (x, y), using its visible bounds
    # for the patch dimensions. Pixels outside the destination are preserved.
    def update_rect(x : Int32, y : Int32, source : CrImage::Image) : Nil
      check_available
      CrImageAdapter.with_pixels(source, premultiplied: @format == Format::RGBA8Premultiplied) do |pixels, width, height, stride|
        update_rect(x, y, width, height, pixels, byte_stride: stride)
      end
    end
  end

  class Image
    # Creates a native image from any CrImage image. The caller owns the result.
    def self.from_crimage(source : CrImage::Image) : Image
      width, height = CrImageAdapter.dimensions(source)
      image = new(width, height)
      begin
        image.append(source)
      rescue error
        image.free
        raise error
      end
      image
    end

    # Reads an image by content, independently of its file extension.
    # The caller owns the returned native image.
    def self.from_file(path : String) : Image
      File.open(path) { |file| from_crimage(CrImage.read(file)) }
    end

    # Adds a CrImage representation, for example a higher resolution icon.
    def append(source : CrImage::Image) : Nil
      CrImageAdapter.with_pixels(source) do |pixels, width, height, stride|
        append(pixels, width, height, stride)
      end
    end
  end

  class ImageView
    def initialize(source : CrImage::Image, mode : ContentMode = ContentMode::Fit)
      image = Image.from_crimage(source)
      begin
        @ref_ptr = LibUI.new_image_view
        LibUI.image_view_set_image(ref_ptr, image.to_unsafe)
        LibUI.image_view_set_content_mode(ref_ptr, mode)
        register_control
      ensure
        image.free
      end
    end

    def image=(source : CrImage::Image)
      image = Image.from_crimage(source)
      begin
        self.image = image
      ensure
        image.free
      end
    end
  end

  class ColorButton
    def set_color(color : CrImage::Color::Color) : Nil
      set_color(*CrImageAdapter.rgba(color))
    end

    # Sets a CrImage color while leaving the numeric RGBA getter unchanged.
    def color=(color : CrImage::Color::Color) : Nil
      set_color(color)
    end

    def color_crimage : CrImage::Color::NRGBA
      r, g, b, a = color
      CrImage::Color::NRGBA.new(
        CrImageAdapter.byte(r), CrImageAdapter.byte(g),
        CrImageAdapter.byte(b), CrImageAdapter.byte(a)
      )
    end
  end

  class Toolbar
    def append_button(text : String, icon : CrImage::Image) : ToolbarItem
      check_mutable
      CrImageAdapter.with_image(icon) { |image| append_button(text, image) }
    end

    def append_button(text : String, icon : CrImage::Image, &) : ToolbarItem
      item = append_button(text, icon)
      with item yield item
      item
    end

    def append_toggle_button(text : String, icon : CrImage::Image) : ToolbarItem
      check_mutable
      CrImageAdapter.with_image(icon) { |image| append_toggle_button(text, image) }
    end

    def append_toggle_button(text : String, icon : CrImage::Image, &) : ToolbarItem
      item = append_toggle_button(text, icon)
      with item yield item
      item
    end
  end

  class ToolbarItem
    # Toolbar items copy their icons; the temporary native image is freed here.
    def icon=(source : CrImage::Image) : Nil
      ref_ptr
      CrImageAdapter.with_image(source) { |image| self.icon = image }
    end
  end

  class Area < Control
    class Attribute
      def self.new_color(color : CrImage::Color::Color) : Attribute
        new_color(*CrImageAdapter.rgba(color))
      end

      def self.new_background(color : CrImage::Color::Color) : Attribute
        new_background(*CrImageAdapter.rgba(color))
      end

      def self.new_underline_color(kind : UnderlineColor, color : CrImage::Color::Color) : Attribute
        new_underline_color(kind, *CrImageAdapter.rgba(color))
      end
    end

    module Draw
      class Brush
        def self.solid(color : CrImage::Color::Color) : Brush
          new(Type::Solid, *CrImageAdapter.rgba(color))
        end

        def color=(color : CrImage::Color::Color) : Nil
          red, green, blue, alpha = CrImageAdapter.rgba(color)
          self.r = red
          self.g = green
          self.b = blue
          self.a = alpha
        end

        # Copies geometry and color stops. Interpolation uses the native backend.
        def self.from_crimage(gradient : CrImage::Draw::LinearGradient) : Brush
          CrImage::InputValidation.validate_color_stops(gradient.stops)
          new(Type::LinearGradient,
            x0: gradient.start_point.x, y0: gradient.start_point.y,
            x1: gradient.end_point.x, y1: gradient.end_point.y,
            stops: gradient.stops.map { |stop| GradientStop.new(stop) })
        end

        def self.from_crimage(gradient : CrImage::Draw::RadialGradient) : Brush
          CrImage::InputValidation.validate_color_stops(gradient.stops)
          radius = NumericValue.positive(gradient.radius, "radial gradient radius")
          new(Type::RadialGradient,
            x0: gradient.center.x, y0: gradient.center.y,
            x1: gradient.center.x, y1: gradient.center.y, outer_radius: radius,
            stops: gradient.stops.map { |stop| GradientStop.new(stop) })
        end

        class GradientStop
          def initialize(pos : Number, color : CrImage::Color::Color)
            initialize(pos, *CrImageAdapter.rgba(color))
          end

          def initialize(stop : CrImage::Draw::ColorStop)
            initialize(stop.position, stop.color)
          end

          def color=(color : CrImage::Color::Color) : Nil
            red, green, blue, alpha = CrImageAdapter.rgba(color)
            self.r = red
            self.g = green
            self.b = blue
            self.a = alpha
          end
        end
      end
    end
  end

  class Table < Control
    class Value
      def self.new_color(color : CrImage::Color::Color) : Value
        new_color(*CrImageAdapter.rgba(color))
      end
    end
  end
end

module CrImage
  module Image
    # Converts to an owned UIng image. Call `free` when it is no longer in use.
    def to_uing_image : UIng::Image
      UIng::Image.from_crimage(self)
    end
  end

  module Color
    module Color
      # Returns straight RGBA components in UIng's 0.0..1.0 range.
      def to_uing_rgba : {Float64, Float64, Float64, Float64}
        UIng::CrImageAdapter.rgba(self)
      end
    end
  end
end
