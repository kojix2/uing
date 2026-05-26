module UIng
  class Image
    @released : Bool = false

    def initialize(@ref_ptr : Pointer(LibUI::Image))
    end

    def initialize(width : Number, height : Number)
      @ref_ptr = LibUI.new_image(width.to_f64, height.to_f64)
    end

    def append(pixels, pixel_width : Int32, pixel_height : Int32, byte_stride : Int32) : Nil
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
