require "./control"

module UIng
  class Grid
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Grid))
    end

    def initialize
      @ref_ptr = LibUI.new_grid
    end

    def to_unsafe
      @ref_ptr
    end

    def padded=(value : Bool)
      set_padded(value ? 1 : 0)
    end
  end
end
