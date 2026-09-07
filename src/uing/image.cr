module UIng
  class Image
    @released : Bool = false

    def initialize(@ref_ptr : Pointer(LibUI::Image))
    end

    def initialize(width : Number, height : Number)
      logical_width = checked_logical_dimension(width, "width")
      logical_height = checked_logical_dimension(height, "height")
      @ref_ptr = LibUI.new_image(logical_width, logical_height)
    end

    def append(pixels : Bytes, pixel_width : Int32, pixel_height : Int32, byte_stride : Int32) : Nil
      check_available
      required_bytes = checked_pixel_buffer_size(pixel_width, pixel_height, byte_stride)
      if pixels.size < required_bytes
        raise ArgumentError.new("pixel buffer is too small: expected at least #{required_bytes} bytes, got #{pixels.size}")
      end

      LibUI.image_append(@ref_ptr, pixels, pixel_width, pixel_height, byte_stride)
    end

    # The caller is responsible for ensuring that the pointer references at least
    # `byte_stride * pixel_height` readable bytes.
    def append(pixels : Pointer, pixel_width : Int32, pixel_height : Int32, byte_stride : Int32) : Nil
      check_available
      checked_pixel_buffer_size(pixel_width, pixel_height, byte_stride)
      LibUI.image_append(@ref_ptr, pixels, pixel_width, pixel_height, byte_stride)
    end

    def free : Nil
      return if @released
      LibUI.free_image(@ref_ptr)
      @released = true
    end

    private def check_available : Nil
      raise "Image has already been released" if @released
    end

    def to_unsafe
      check_available
      @ref_ptr
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
      required_bytes
    end
  end
end
