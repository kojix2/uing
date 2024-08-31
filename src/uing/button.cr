module UIng
  class Button
    def initialize(@ref_ptr : Pointer(LibUI::Button))
    end

    def initialize
      @ref_ptr = LibUI.new_button
    end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
