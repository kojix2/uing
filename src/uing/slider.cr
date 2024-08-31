module UIng
  class Slider
    def initialize(@ref_ptr : Pointer(LibUI::Slider))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_slider
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
