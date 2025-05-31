require "./control"

module UIng
  class Grid
    include Control; block_constructor

    def initialize(@ref_ptr : Pointer(LibUI::Grid))
    end

    def initialize
      @ref_ptr = LibUI.new_grid
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
