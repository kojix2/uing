module UIng
  class Image
    @released : Bool = false

    def initialize(@ref_ptr : Pointer(LibUI::Image))
    end

    def initialize(width : Number, height : Number)
      @ref_ptr = LibUI.new_image(width.to_f64, height.to_f64)
    end

    def append(pixels : Bytes, pixel_width : Int32, pixel_height : Int32, byte_stride : Int32) : Nil
      check_available

      raise ArgumentError.new("pixel width must be positive") unless pixel_width > 0
      raise ArgumentError.new("pixel height must be positive") unless pixel_height > 0

      row_bytes = pixel_width.to_i64 * 4
      raise ArgumentError.new("byte stride is too small for RGBA pixels") unless byte_stride >= row_bytes

      required_bytes = byte_stride.to_i64 * pixel_height
      if pixels.size < required_bytes
        raise ArgumentError.new("pixel buffer is too small: expected at least #{required_bytes} bytes, got #{pixels.size}")
      end

      LibUI.image_append(@ref_ptr, pixels, pixel_width, pixel_height, byte_stride)
    end

    # The caller is responsible for ensuring that the pointer references at least
    # `byte_stride * pixel_height` readable bytes.
    def append(pixels : Pointer, pixel_width : Int32, pixel_height : Int32, byte_stride : Int32) : Nil
      check_available
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
  end
end
