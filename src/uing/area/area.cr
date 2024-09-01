module UIng
  class Area
    def initialize(@ref_ptr : Pointer(LibUI::Area))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_area
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
