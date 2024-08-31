module UIng
  class Tab
    def initialize(@ref_ptr : Pointer(LibUI::Tab))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_tab
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
