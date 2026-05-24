module UIng
  class Image
    @released : Bool = false

    def initialize(@ref_ptr : Pointer(LibUI::Image))
    end

    def initialize(width : Number, height : Number)
      @ref_ptr = LibUI.new_image(width.to_f64, height.to_f64)
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
