module UIng
  class Grid
    def initialize(@ref_ptr : Pointer(LibUI::Grid))
    end

    def initialize
      @ref_ptr = LibUI.new_grid
    end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
