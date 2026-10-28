module UIng
  # A mutable, fixed-resolution RGBA image. All native operations must run on
  # the UI thread between UIng.init and UIng.uninit. Call free explicitly or
  # use open; native resources are not released by a GC finalizer.
  # Requires ImageBuffer-capable libui-ng (dev da49cf29 or later); the binary
  # currently pinned in download.cr predates this API.
  class ImageBuffer
    alias Format = LibUI::ImageBufferFormat
    alias Interpolation = LibUI::ImageBufferInterpolation
    alias SourceRect = NamedTuple(x: Int32, y: Int32, width: Int32, height: Int32)

    class Error < Exception
    end

    @ref_ptr : Pointer(LibUI::ImageBuffer)
    @released = false

    def initialize(@width : Int32, @height : Int32, *, @format : Format = Format::RGBA8Straight)
      raise ArgumentError.new("pixel width must be positive") unless @width > 0
      raise ArgumentError.new("pixel height must be positive") unless @height > 0
      unless @format == Format::RGBA8Straight || @format == Format::RGBA8Premultiplied
        raise ArgumentError.new("unsupported image buffer format")
      end
      storage_size = @width.to_u64 * @height.to_u64 * 4
      if storage_size > LibC::SizeT::MAX // 2
        raise ArgumentError.new("pixel buffer is too large to address on this platform")
      end
      @ref_ptr = LibUI.new_image_buffer(@width, @height, @format)
      raise Error.new("could not create image buffer") if @ref_ptr.null?
    end

    # Always frees the buffer, including on exceptions; returns the block value.
    # Keep the event loop inside the block when callbacks refer to this buffer.
    def self.open(width : Int32, height : Int32, *, format : Format = Format::RGBA8Straight, &)
      buffer = new(width, height, format: format)
      begin
        yield buffer
      ensure
        buffer.free
      end
    end

    # Pixel dimensions, independent of drawing coordinates or display DPI.
    def size : {Int32, Int32}
      check_available
      {@width, @height}
    end

    def width : Int32
      size[0]
    end

    def height : Int32
      size[1]
    end

    def format : Format
      check_available
      @format
    end

    def released? : Bool
      @released
    end

    # Copies the input before return. Final-row padding is optional. Straight
    # RGBA is premultiplied natively; premultiplied input requires R, G, B <= A.
    # Updates do not request a redraw; call Area#queue_redraw_all as needed.
    def update(pixels : Bytes, *, byte_stride : Int = @width.to_i64 * 4) : Nil
      check_available
      stride = checked_stride(pixels, @width, @height, byte_stride)
      if LibUI.image_buffer_update(@ref_ptr, pixels, pixels.size, stride) == 0
        raise Error.new("could not update image buffer; previous pixels are unchanged")
      end
    end

    # pixels starts at the patch's top-left pixel. The rectangle must fit fully
    # inside this buffer; pixels outside it are preserved, without compositing.
    def update_rect(x : Int32, y : Int32, width : Int32, height : Int32,
                    pixels : Bytes, *, byte_stride : Int = width.to_i64 * 4) : Nil
      check_available
      unless x >= 0 && y >= 0 && width > 0 && height > 0 &&
             x <= @width && y <= @height &&
             width <= @width - x && height <= @height - y
        raise ArgumentError.new("update rectangle must be positive and fit inside the image buffer")
      end
      stride = checked_stride(pixels, width, height, byte_stride)
      if LibUI.image_buffer_update_rect(@ref_ptr, x, y, width, height, pixels, pixels.size, stride) == 0
        raise Error.new("could not update image buffer rectangle; previous pixels are unchanged")
      end
    end

    # Idempotent. Already submitted draws remain valid after this call.
    def free : Nil
      return if @released
      LibUI.free_image_buffer(@ref_ptr)
      @released = true
      @ref_ptr = Pointer(LibUI::ImageBuffer).null
    end

    def to_unsafe : Pointer(LibUI::ImageBuffer)
      check_available
      @ref_ptr
    end

    private def check_available : Nil
      raise RuntimeError.new("ImageBuffer has already been released") if @released
    end

    private def checked_stride(pixels : Bytes, width : Int32, height : Int32, byte_stride : Int) : LibC::SizeT
      row_bytes = width.to_u64 * 4
      if byte_stride < row_bytes || byte_stride > LibC::SizeT::MAX
        raise ArgumentError.new("byte stride must cover an RGBA row and fit in size_t")
      end
      stride = byte_stride.to_u64
      rows = height.to_u64 - 1
      if row_bytes > LibC::SizeT::MAX || rows > (LibC::SizeT::MAX.to_u64 - row_bytes) // stride
        raise ArgumentError.new("pixel buffer span is too large to address on this platform")
      end
      required = rows * stride + row_bytes
      if required > pixels.size
        raise ArgumentError.new("pixel buffer is too small: expected at least #{required} bytes, got #{pixels.size}")
      end
      LibC::SizeT.new(stride)
    end
  end
end
