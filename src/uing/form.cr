module UIng
  class Form
    def initialize(@ref_ptr : Pointer(LibUI::Form))
    end

    def initialize
      @ref_ptr = LibUI.new_form
    end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
