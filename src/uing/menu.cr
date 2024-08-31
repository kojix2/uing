module UIng
  class Menu
    def initialize(@ref_ptr : Pointer(LibUI::Menu))
    end

    def initialize
      @ref_ptr = LibUI.new_menu
    end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
