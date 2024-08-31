module UIng
  class Image
    def initialize(@ref_ptr : Pointer(LibUI::Image))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_image
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
