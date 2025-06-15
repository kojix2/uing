module UIng
  class Image
    property? released : Bool = false

    def initialize(@ref_ptr : Pointer(LibUI::Image))
    end

    def initialize(width : Int32, height : Int32)
      @ref_ptr = LibUI.new_image(width, height)
    end

    def append(pixels, pixel_width : Int32, pixel_height : Int32, byte_stride : Int32) : Nil
      LibUI.image_append(@ref_ptr, pixels, pixel_width, pixel_height, byte_stride)
    end

    def free : Nil
      return if @released
      LibUI.free_image(@ref_ptr)
      @released = true
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
