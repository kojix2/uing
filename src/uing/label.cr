module UIng
  class Label
    def initialize(@ref_ptr : Pointer(LibUI::Label))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_label
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end