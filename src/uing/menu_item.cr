module UIng
  class MenuItem
    def initialize(@ref_ptr : Pointer(LibUI::MenuItem))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_menu_item
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
