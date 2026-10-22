module UIng
  class Image
    @released : Bool = false
    @representations = [] of Tuple(Bytes, Int32, Int32, Int32)

    protected def initialize(@ref_ptr : Pointer(LibUI::Image))
    end

    def initialize(width : Number, height : Number)
      logical_width = checked_logical_dimension(width, "width")
      logical_height = checked_logical_dimension(height, "height")
      @ref_ptr = LibUI.new_image(logical_width, logical_height)
    end

    # Returns the image's logical dimensions in points.
    def size : {Float64, Float64}
      check_available
      LibUI.image_get_size(@ref_ptr, out width, out height)
      {width, height}
    end

    def width : Float64
      size[0]
    end

    def height : Float64
      size[1]
    end

    def append(pixels : Bytes, pixel_width : Int32, pixel_height : Int32, byte_stride : Int32) : Nil
      check_available
      required_bytes = checked_pixel_buffer_size(pixel_width, pixel_height, byte_stride)
      if pixels.size < required_bytes
        raise ArgumentError.new("pixel buffer is too small: expected at least #{required_bytes} bytes, got #{pixels.size}")
      end

      stored_pixels = pixels[0, required_bytes.to_i].dup
      LibUI.image_append(@ref_ptr, stored_pixels, pixel_width, pixel_height, byte_stride)
      @representations << {stored_pixels, pixel_width, pixel_height, byte_stride}
    end

    # The caller is responsible for ensuring that the pointer references at least
    # `byte_stride * pixel_height` readable bytes.
    def append(pixels : Pointer, pixel_width : Int32, pixel_height : Int32, byte_stride : Int32) : Nil
      check_available
      required_bytes = checked_pixel_buffer_size(pixel_width, pixel_height, byte_stride)
      stored_pixels = pixels.as(Pointer(UInt8)).to_slice(required_bytes.to_i).dup
      LibUI.image_append(@ref_ptr, stored_pixels, pixel_width, pixel_height, byte_stride)
      @representations << {stored_pixels, pixel_width, pixel_height, byte_stride}
    end

    # Returns an independent native image with the same pixel representations.
    def copy : Image
      check_available
      width, height = size
      copy = Image.new(width, height)
      begin
        @representations.each do |representation|
          copy.append_stored_representation(representation)
        end
        copy
      rescue error
        copy.free
        raise error
      end
    end

    def free : Nil
      return if @released
      LibUI.free_image(@ref_ptr)
      @released = true
      @representations.clear
    end

    private def check_available : Nil
      raise "Image has already been released" if @released
    end

    def to_unsafe
      check_available
      @ref_ptr
    end

    protected def append_stored_representation(representation : Tuple(Bytes, Int32, Int32, Int32)) : Nil
      pixels, pixel_width, pixel_height, byte_stride = representation
      LibUI.image_append(@ref_ptr, pixels, pixel_width, pixel_height, byte_stride)
      @representations << representation
    end

    private def checked_logical_dimension(value : Number, name : String) : Float64
      dimension = value.to_f64
      unless dimension.finite? && dimension > 0 && dimension <= Int32::MAX
        raise ArgumentError.new("image #{name} must be finite, positive, and no greater than Int32::MAX")
      end
      dimension
    end

    private def checked_pixel_buffer_size(pixel_width : Int32, pixel_height : Int32, byte_stride : Int32) : Int64
      raise ArgumentError.new("pixel width must be positive") unless pixel_width > 0
      raise ArgumentError.new("pixel height must be positive") unless pixel_height > 0
      if pixel_width > Int32::MAX // 4
        raise ArgumentError.new("pixel width is too large for 32-bit RGBA pixels")
      end

      row_bytes = pixel_width.to_i64 * 4
      raise ArgumentError.new("byte stride is too small for RGBA pixels") unless byte_stride >= row_bytes

      required_bytes = byte_stride.to_i64 * pixel_height
      if required_bytes > LibC::SizeT::MAX
        raise ArgumentError.new("pixel buffer is too large to address on this platform")
      end
      if required_bytes > Int32::MAX
        raise ArgumentError.new("pixel buffer is too large to retain for copying")
      end
      required_bytes
    end
  end
end
