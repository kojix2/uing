module UIng
  class Spinbox
    def initialize(@ref_ptr : Pointer(LibUI::Spinbox))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_spinbox
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
