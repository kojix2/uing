module UIng
  lib LibUI
    # All operations require the UI thread between uiInit() and uiUninit().
    # Buffers have fixed pixel dimensions and must be freed exactly once.
    alias ImageBuffer = Void

    # Input bytes are R, G, B, A, independent of host endianness.
    enum ImageBufferFormat : UInt32
      RGBA8Straight      = 0
      RGBA8Premultiplied = 1
    end

    enum ImageBufferInterpolation : UInt32
      Smooth  = 0
      Nearest = 1
    end

    # Set size to sizeof(DrawImageBufferParams) and initialize every field.
    # Source coordinates are pixels; destination coordinates are user units.
    struct DrawImageBufferParams
      size : LibC::SizeT
      source_x : LibC::Int
      source_y : LibC::Int
      source_width : LibC::Int
      source_height : LibC::Int
      x : LibC::Double
      y : LibC::Double
      width : LibC::Double
      height : LibC::Double
      interpolation : ImageBufferInterpolation
    end

    # Returns NULL for invalid arguments or recoverable allocation failure.
    fun new_image_buffer = uiNewImageBuffer(pixel_width : LibC::Int, pixel_height : LibC::Int, format : ImageBufferFormat) : Pointer(ImageBuffer)
    fun free_image_buffer = uiFreeImageBuffer(buffer : Pointer(ImageBuffer))
    fun image_buffer_get_size = uiImageBufferGetSize(buffer : Pointer(ImageBuffer), pixel_width : Pointer(LibC::Int), pixel_height : Pointer(LibC::Int))

    # Updates copy the input before returning and return 1 on success, 0 on
    # failure. byte_length must be the actual readable allocation length;
    # (height - 1) * byte_stride + width * 4 bytes are required. Updates do not
    # request a redraw. Premultiplied input requires R, G, B <= A.
    fun image_buffer_update = uiImageBufferUpdate(buffer : Pointer(ImageBuffer), pixels : Pointer(Void), byte_length : LibC::SizeT, byte_stride : LibC::SizeT) : LibC::Int
    fun image_buffer_update_rect = uiImageBufferUpdateRect(buffer : Pointer(ImageBuffer), x : LibC::Int, y : LibC::Int, width : LibC::Int, height : LibC::Int, pixels : Pointer(Void), byte_length : LibC::SizeT, byte_stride : LibC::SizeT) : LibC::Int

    # Only call inside an Area Draw callback. Submitted draws survive later
    # updates and buffer destruction, including destruction in that callback.
    fun draw_image_buffer = uiDrawImageBuffer(c : Pointer(DrawContext), buffer : Pointer(ImageBuffer), x : LibC::Double, y : LibC::Double, width : LibC::Double, height : LibC::Double, interpolation : ImageBufferInterpolation)
    fun draw_image_buffer_with_params = uiDrawImageBufferWithParams(c : Pointer(DrawContext), buffer : Pointer(ImageBuffer), params : Pointer(DrawImageBufferParams))
  end
end
