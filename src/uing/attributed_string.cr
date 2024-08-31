module UIng
  class AttributedString
    def initialize(@ref_ptr : Pointer(LibUI::AttributedString))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_attributed_string
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
